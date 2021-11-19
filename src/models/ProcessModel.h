/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QFileInfo>
#include <KIO/CopyJob>

class ProcessModel;
static ProcessModel *s_processModel = nullptr;

class ProcessModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool isCopying READ isCopying NOTIFY copyingChanged)
public:
    explicit ProcessModel(QObject *parent = nullptr);
    virtual ~ProcessModel();

    static ProcessModel* instance()
    {
        if (!s_processModel) {
            s_processModel = new ProcessModel();
        }
        return s_processModel;
    }

    enum ModelDataRoles {
        Data_Job = 1,
        Data_TotalSize = 2,
        Data_ProcessedSize = 3,
        Data_SupportKill = 4,
        Data_SupportSuspend = 5,
        Data_IsSuspended = 6,
        Data_TotalFiles= 7
    };
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    Q_INVOKABLE void insertCopyJob(QStringList where, QUrl url);
    Q_INVOKABLE bool insertCutJob(const QStringList &urls, const QUrl &where);
    Q_INVOKABLE bool killJob(KJob *job);
    Q_INVOKABLE bool suspendJob(KJob *job);
    Q_INVOKABLE bool resumeJob(KJob *job);
    Q_INVOKABLE bool isCopyingFile(QString path);
    Q_INVOKABLE void clearJobList();
    QString sizeFormat(quint64 size) const;
    bool isCopying() {
        m_copying = m_jobs.size() > 0;
        return m_copying;
    }
private:
    bool addCopyJob(KJob *job);
private:
    bool m_copying = false;
    QHash<QString,QString> m_copyingFiles;
public slots:
    void onJobResult(KJob *job);
Q_SIGNALS:
   void copyingChanged();
   void noteIconChanged();
   void cutCompleteChanged();
   void copyErrorNotify(QString errorText);

private:
    QList<KJob*> m_jobs;

};
