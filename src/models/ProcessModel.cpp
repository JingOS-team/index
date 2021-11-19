/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
#include "ProcessModel.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrentRun>
#include <QThreadPool>
#include <QUrl>
#include <QCoreApplication>
#include <KLocalizedString>

ProcessModel::ProcessModel(QObject *parent)
    :QAbstractListModel(parent)
{
    QObject::connect(qApp, &QCoreApplication::aboutToQuit, [this](){
           qDebug() << "----------aboutToQuit";
           foreach (auto job, m_jobs) {
               if (job) {
                  job->kill(KJob::EmitResult);
               }
           }
       });
}

ProcessModel::~ProcessModel()
{
}

QHash<int, QByteArray> ProcessModel::roleNames() const
{
    QHash<int, QByteArray> roleNames { { ProcessModel::Data_Job, "job" },
                                       { ProcessModel::Data_TotalSize, "totalSize"},
                                       { ProcessModel::Data_TotalFiles, "totalFiles"},
                                       { ProcessModel::Data_ProcessedSize, "processedSize"},
                                       { ProcessModel::Data_SupportKill, "isKill"},
                                       { ProcessModel::Data_SupportSuspend, "isSuspend"},
                                       { ProcessModel::Data_IsSuspended, "isSuspended"}
                                     };

    return roleNames;
}
int ProcessModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_jobs.size();
}

QVariant ProcessModel::data(const QModelIndex &index, int role) const
{
    int indexValue = index.row();
    if (m_jobs.size() - 1 < indexValue) {
        return QVariant();
    }
     auto job = m_jobs.at(indexValue);
     if (!job) {
         return QVariant();
     }
    if (role == ProcessModel::Data_Job) {
        QVariant var = QVariant::fromValue(job);
        return var;
    } else if (role == ProcessModel::Data_TotalSize) {
        qulonglong totalSize = job->totalAmount(KJob::Bytes);
        QString totalStr = sizeFormat(totalSize);
        return totalStr;
    }  else if (role == ProcessModel::Data_TotalFiles) {
        qulonglong totalSize = job->totalAmount(KJob::Files);
        return totalSize;
    } else if (role == ProcessModel::Data_ProcessedSize) {
        qulonglong processSize = job->processedAmount(KJob::Bytes);
        QString processStr = sizeFormat(processSize);
        return processStr;
    }else if (role == ProcessModel::Data_SupportKill) {
        return job->capabilities().testFlag(KJob::Killable);
    } else if (role == ProcessModel::Data_SupportSuspend) {
        return job->capabilities().testFlag(KJob::Suspendable);
    } else if (role == ProcessModel::Data_IsSuspended) {
        return job->isSuspended();
    }

    return QVariant();
}

void ProcessModel::insertCopyJob(QStringList where, QUrl url)
{
    if (m_jobs.size() > 3) {
        emit copyErrorNotify(i18n("You can only paste 4 items simultaneously, please try again later"));
        return ;
    }
    auto job = KIO::copy(QUrl::fromStringList(where), url,KIO::HideProgressInfo);
    job->setAutoRename(true);
    QObject::connect(job, &KJob::result, [=] (KJob *job) {
        if (job->error()) {
            qWarning() << "@@@@ slotResult error == " << job->errorString();
        }
        onJobResult(job);
    });
    QObject::connect(job, &KIO::CopyJob::copying, [=] (KIO::Job *job, const QUrl &src, const QUrl &dest) {
        qDebug() << " COPYING SRC " << src << " DEST" << dest.toString();
        if (m_copyingFiles.contains(dest.toString())) {
             m_copyingFiles.remove(dest.toString());
        } else {
            m_copyingFiles.insert(dest.toString(),"Copying");
        }
    });
    QObject::connect(job, &KIO::CopyJob::copyingDone, [=] (KIO::Job *job, const QUrl &from, const QUrl &to, const QDateTime &mtime, bool directory, bool renamed) {
        qDebug() << "COPYINGDONE FROM " << from << " TO" << to.toString() << " mtime:" << mtime << " directory:" << directory << " renamed:" << renamed;
        if (m_copyingFiles.contains(to.toString())) {
            m_copyingFiles.remove(to.toString());
        } else {
            m_copyingFiles.insert(to.toString(),"Copying");
        }
    });
    job->start();
    addCopyJob(job);
    emit copyingChanged();
}

bool ProcessModel::insertCutJob(const QStringList &urls, const QUrl &where)
{
    if (m_jobs.size() > 3) {
        emit copyErrorNotify(i18n("You can only paste 4 items simultaneously, please try again later"));
        return false;
    }
    QUrl _where = where;
    auto job = KIO::move(QUrl::fromStringList(urls), _where, KIO::HideProgressInfo);
    job->setAutoRename(true);
    QObject::connect(job, &KJob::result, [=] (KJob *job) {
        if (job->error()) {
            qWarning() << "@@@@ insertCutJob error == " << job->errorString();
        }
        onJobResult(job);
        emit cutCompleteChanged();
    });

    job->start();
    addCopyJob(job);
    emit copyingChanged();
    return true;
}

bool ProcessModel::addCopyJob(KJob *job)
{
    beginInsertRows({}, m_jobs.size(), m_jobs.size());
    m_jobs.append(job);
    endInsertRows();
    return true;
}


void ProcessModel::onJobResult(KJob *job)
{
    beginResetModel();
    m_jobs.removeOne(job);
    emit copyingChanged();
    if (m_jobs.size() <= 0) {
        clearJobList();
    }
    endResetModel();
}

bool ProcessModel::killJob(KJob *job)
{
    bool isSuc = false;
    if (job) {
        isSuc = job->kill(KJob::EmitResult);
    }
    return isSuc;
}

bool ProcessModel::suspendJob(KJob *job)
{
    bool isSuc = false;
    if (job) {
        isSuc = job->suspend();
    }
    return isSuc;
}

bool ProcessModel::resumeJob(KJob *job)
{
    bool isSuc = false;
    if (job) {
        isSuc = job->resume();
    }
    return isSuc;
}

bool ProcessModel::isCopyingFile(QString path)
{
    bool isCopying = m_copyingFiles.contains(path);
    return isCopying;
}

void ProcessModel::clearJobList()
{
    m_copyingFiles.clear();
    m_jobs.clear();
}

QString ProcessModel::sizeFormat(quint64 size) const
{
    qreal calc = size;
    QStringList list;
    list << "KB" << "MB" << "GB" << "TB";

    QStringListIterator i(list);
    QString unit("B");

    while(calc >= 1024.0 && i.hasNext())
    {
        unit = i.next();
        calc /= 1024.0;
    }

    return QString().setNum(calc, 'f', 2) + " " + unit;
}
