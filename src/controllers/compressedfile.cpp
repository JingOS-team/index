/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
#include "compressedfile.h"

#include <KArchive/KTar>
#include <KArchive/KZip>
#include <KArchive/kcompressiondevice.h>
#include <KArchive/kfilterdev.h>

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include <KArchive/k7zip.h>
#endif

#include <KArchive/kar.h>
#include <qdiriterator.h>
#include <QFuture>
#include <QtConcurrent>

CompressedFile::CompressedFile(QObject *parent)
    : QObject(parent)
    , m_model(new CompressedFileModel(this))
{
}

CompressedFileModel::CompressedFileModel(QObject *parent)
    : MauiList(parent)
{
}

const FMH::MODEL_LIST &CompressedFileModel::items() const
{
    return m_list;
}

void CompressedFileModel::setUrl(const QUrl &url)
{
    emit this->preListChanged();
    m_list.clear();

    KArchive *kArch = CompressedFile::getKArchiveObject(url);
    kArch->open(QIODevice::ReadOnly);
    assert(kArch->isOpen() == true);
    if (kArch->isOpen()) {
        for (auto entry : kArch->directory()->entries()) {
            auto e = kArch->directory()->entry(entry);

            this->m_list << FMH::MODEL{{FMH::MODEL_KEY::LABEL, e->name()}, {FMH::MODEL_KEY::ICON, e->isDirectory() ? "folder" : FMH::getIconName(e->name())}, {FMH::MODEL_KEY::DATE, e->date().toString()}};
        }
    }

    emit this->postListChanged();
}

QString CompressedFile::checkFileName(const QUrl &where, const QString &fileName, const bool isExtract)
{
    QString newName = fileName;
    int index = newName.lastIndexOf(".");
    if(index != -1)
    {
        newName = newName.mid(0, index);
    }
    QString dir_str = where.toString() + "/" + newName;
    dir_str.replace(QString("file://"), QString(""));
    QDir dir;

    if(isExtract)
    {
        QString folderName = dir_str;
        if(!dir.exists(folderName))
        {
            return newName;
        }else
        {
            int count = 1;
            while(dir.exists(dir_str + QString::number(count)))
            {
                count++;
            }
            return newName + QString::number(count);
        }
    }else
    {
        if(!dir.exists(dir_str + ".zip"))
        {
            return newName;
        }else
        {
            int count = 1;
            while(dir.exists(dir_str + QString::number(count) + ".zip"))
            {
                count++;
            }
            return newName + QString::number(count);
        }
    }
}

void CompressedFile::extractWithThread(const QUrl &where, const QString &directory, const QUrl &archUrl)
{
    if (m_decompressed) {
        emit tipMessage("decompressing");
        return;
    }
    setDecompress(true);
    QFutureWatcher<QString> *watcher = new QFutureWatcher<QString>;
    connect(watcher, &QFutureWatcher<uint>::finished, [&, watcher]()
    {
        const auto filePath = watcher->future().result();
        emit this->finishZip(filePath);
        setDecompress(false);
        watcher->deleteLater();
    });

    const auto func = [=]() -> QString
    {
        setUrl(archUrl);
        QString name = checkFileName(where, directory, true);
        QString signalsName = where.toString() + "/" + name;
        emit this->startZip(signalsName);
        extract(where, name);
        return signalsName;
    };

    QFuture<QString> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);
}

void CompressedFile::extract(const QUrl &where, const QString &directory)
{
    if (!m_url.isLocalFile())
        return;

    QString where_ = where.toLocalFile() + "/" + directory;

    auto kArch = CompressedFile::getKArchiveObject(m_url);
    kArch->open(QIODevice::ReadOnly);
    assert(kArch->isOpen() == true);
    if (kArch->isOpen()) {
        bool recursive = true;
        kArch->directory()->copyTo(where_, recursive);
    }
}


bool CompressedFile::compressWithThread(const QVariantList &files, const QUrl &where, const QString &fileName, const int &compressTypeSelected)
{
    if (m_compressed) {
        emit tipMessage("compressing");
        return false;
    }
    setCompress(true);
    QFutureWatcher<QString> *watcher = new QFutureWatcher<QString>;
    connect(watcher, &QFutureWatcher<QString>::finished, [&, watcher]()
    {
        setCompress(false);
        const auto filePath = watcher->future().result();
        emit this->finishZip(filePath);
        watcher->deleteLater();
    });

    const auto func = [=]() -> QString
    {
        QString name = checkFileName(where, fileName, false);
        QString signalsName = where.toString() + "/" + name + ".zip";
        emit this->startZip(signalsName);
        compress(files, where, name, compressTypeSelected);
        return signalsName;
    };

    QFuture<QString> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);

    return true;
}

/*
 *
 *  CompressTypeSelected is an integer and has to be acorrding with order in Dialog.qml
 *
 */
bool CompressedFile::compress(const QVariantList &files, const QUrl &where, const QString &fileName, const int &compressTypeSelected)
{
    bool error = true;
    assert(compressTypeSelected >= 0 && compressTypeSelected <= 8);
    for (auto uri : files) {
        if (!QFileInfo(QUrl(uri.toString()).toLocalFile()).isDir()) {
            auto file = QFile(QUrl(uri.toString()).toLocalFile());
            file.open(QIODevice::ReadWrite);
            if (file.isOpen() == true) {
                switch (compressTypeSelected) {
                case 0: //.ZIP
                {
                    auto kzip = new KZip(QUrl(where.toString() + "/" + fileName + ".zip").toLocalFile());
                    kzip->open(QIODevice::ReadWrite);
                    assert(kzip->isOpen() == true);

                    error = kzip->writeFile(uri.toString().remove(where.toString(), Qt::CaseSensitivity::CaseSensitive), // Mirror file path in compressed file from current directory
                                            file.readAll(),
                                            0100775,
                                            QFileInfo(file).owner(),
                                            QFileInfo(file).group(),
                                            QDateTime(),
                                            QDateTime(),
                                            QDateTime());
                    (void)kzip->close();
                    // WriteFile returns if the file was written or not,
                    // but this function returns if some error occurs so for this reason it is needed to toggle the value
                    error = !error;
                    break;
                }
                case 1: // .TAR
                {
                    auto ktar = new KTar(QUrl(where.toString() + "/" + fileName + ".tar").toLocalFile());
                    ktar->open(QIODevice::ReadWrite);
                    assert(ktar->isOpen() == true);
                    error = ktar->writeFile(uri.toString().remove(where.toString(), Qt::CaseSensitivity::CaseSensitive), // Mirror file path in compressed file from current directory
                                            file.readAll(),
                                            0100775,
                                            QFileInfo(file).owner(),
                                            QFileInfo(file).group(),
                                            QDateTime(),
                                            QDateTime(),
                                            QDateTime());
                    (void)ktar->close();
                    break;
                }
                case 2: //.7ZIP
                {
#ifdef K7ZIP_H

                    // TODO: KArchive no permite comprimir ficheros del mismo modo que con TAR o ZIP. Hay que hacerlo de otra forma y requiere disponer de una libreria actualizada de KArchive.
                    auto k7zip = new K7Zip(QUrl(where.toString() + "/" + fileName + ".7z").toLocalFile());
                    k7zip->open(QIODevice::ReadWrite);
                    assert(k7zip->isOpen() == true);
                    error = k7zip->writeFile(uri.toString().remove(where.toString(), Qt::CaseSensitivity::CaseSensitive), // Mirror file path in compressed file from current directory
                                             file.readAll(),
                                             0100775,
                                             QFileInfo(file).owner(),
                                             QFileInfo(file).group(),
                                             QDateTime(),
                                             QDateTime(),
                                             QDateTime());
                    k7zip->close();
                    // WriteFile returns if the file was written or not,
                    // but this function returns if some error occurs so for this reason it is needed to toggle the value
                    error = !error;
#endif
                    break;
                }
                case 3: //.AR
                {
                    // TODO: KArchive no permite comprimir ficheros del mismo modo que con TAR o ZIP. Hay que hacerlo de otra forma y requiere disponer de una libreria actualizada de KArchive.
                    auto kar = new KAr(QUrl(where.toString() + "/" + fileName + ".ar").toLocalFile());
                    kar->open(QIODevice::ReadWrite);
                    assert(kar->isOpen() == true);
                    error = kar->writeFile(uri.toString().remove(where.toString(), Qt::CaseSensitivity::CaseSensitive), // Mirror file path in compressed file from current directory
                                           file.readAll(),
                                           0100775,
                                           QFileInfo(file).owner(),
                                           QFileInfo(file).group(),
                                           QDateTime(),
                                           QDateTime(),
                                           QDateTime());
                    (void)kar->close();
                    // WriteFile returns if the file was written or not,
                    // but this function returns if some error occurs so for this reason it is needed to toggle the value
                    error = !error;
                    break;
                }
                default:
                    break;
                }
            } else {
                error = true;
            }
        } else {
            auto dir = QDirIterator(QUrl(uri.toString()).toLocalFile(), QDirIterator::Subdirectories);
            switch (compressTypeSelected) {
            case 0: //.ZIP
            {
                auto kzip = new KZip(QUrl(where.toString() + "/" + fileName + ".zip").toLocalFile());
                kzip->open(QIODevice::ReadWrite);
                assert(kzip->isOpen() == true);
                while (dir.hasNext()) {
                    auto entrie = dir.next();

                    if (QFileInfo(entrie).isFile() == true) {
                        auto file = QFile(entrie);
                        file.open(QIODevice::ReadOnly);
                        error = kzip->writeFile(entrie.remove(QUrl(where).toLocalFile(), Qt::CaseSensitivity::CaseSensitive), // Mirror file path in compressed file from current directory
                                                file.readAll(),
                                                0100775,
                                                QFileInfo(file).owner(),
                                                QFileInfo(file).group(),
                                                QDateTime(),
                                                QDateTime(),
                                                QDateTime());
                        // WriteFile returns if the file was written or not,
                        // but this function returns if some error occurs so for this reason it is needed to toggle the value
                        error = !error;
                    }
                }
                (void)kzip->close();
                break;
            }
            case 1: // .TAR
            {
                auto ktar = new KTar(QUrl(where.toString() + "/" + fileName + ".tar").toLocalFile());
                ktar->open(QIODevice::ReadWrite);
                assert(ktar->isOpen() == true);
                while (dir.hasNext()) {
                    auto entrie = dir.next();
                    if (QFileInfo(entrie).isFile() == true) {
                        auto file = QFile(entrie);
                        file.open(QIODevice::ReadOnly);
                        error = ktar->writeFile(entrie.remove(QUrl(where).toLocalFile(), Qt::CaseSensitivity::CaseSensitive), // Mirror file path in compressed file from current directory
                                                file.readAll(),
                                                0100775,
                                                QFileInfo(file).owner(),
                                                QFileInfo(file).group(),
                                                QDateTime(),
                                                QDateTime(),
                                                QDateTime());
                        // WriteFile returns if the file was written or not,
                        // but this function returns if some error occurs so for this reason it is needed to toggle the value
                        error = !error;
                    }
                }
                (void)ktar->close();
                break;
            }
            case 2: //.7ZIP
            {
#ifdef K7ZIP_H

                auto k7zip = new K7Zip(QUrl(where.toString() + "/" + fileName + ".7z").toLocalFile());
                k7zip->open(QIODevice::ReadWrite);
                assert(k7zip->isOpen() == true);
                while (dir.hasNext()) {
                    auto entrie = dir.next();

                    // qDebug() << entrie << " " << where.toString() << QFileInfo(entrie).isFile();
                    if (QFileInfo(entrie).isFile() == true) {
                        auto file = QFile(entrie);
                        file.open(QIODevice::ReadOnly);
                        // qDebug() << entrie << entrie.remove(QUrl(where).toLocalFile(), Qt::CaseSensitivity::CaseSensitive);
                        error = k7zip->writeFile(entrie.remove(QUrl(where).toLocalFile(), Qt::CaseSensitivity::CaseSensitive), // Mirror file path in compressed file from current directory
                                                 file.readAll(),
                                                 0100775,
                                                 QFileInfo(file).owner(),
                                                 QFileInfo(file).group(),
                                                 QDateTime(),
                                                 QDateTime(),
                                                 QDateTime());
                        // WriteFile returns if the file was written or not,
                        // but this function returns if some error occurs so for this reason it is needed to toggle the value
                        error = !error;
                    }
                    (void)k7zip->close();
                    break;
                }
#endif
                break;
            }
            case 3: //.AR
            {
                auto kAr = new KAr(QUrl(where.toString() + "/" + fileName + ".ar").toLocalFile());
                kAr->open(QIODevice::ReadWrite);
                assert(kAr->isOpen() == true);
                while (dir.hasNext()) {
                    auto entrie = dir.next();

                    if (QFileInfo(entrie).isFile() == true) {
                        auto file = QFile(entrie);
                        file.open(QIODevice::ReadOnly);
                        error = kAr->writeFile(entrie.remove(QUrl(where).toLocalFile(), Qt::CaseSensitivity::CaseSensitive), // Mirror file path in compressed file from current directory
                                               file.readAll(),
                                               0100775,
                                               QFileInfo(file).owner(),
                                               QFileInfo(file).group(),
                                               QDateTime(),
                                               QDateTime(),
                                               QDateTime());
                        // WriteFile returns if the file was written or not,
                        // but this function returns if some error occurs so for this reason it is needed to toggle the value
                        error = !error;
                    }
                }
                (void)kAr->close();
                break;
            }
            default:
                break;
            }
        }
    }

    // kzip->prepareWriting("Hello00000.txt", "gabridc", "gabridc", 1024, 0100777, QDateTime(), QDateTime(), QDateTime());
    // kzip->writeData("Hello", sizeof("Hello"));
    // kzip->finishingWriting();

    return error;
}

KArchive *CompressedFile::getKArchiveObject(const QUrl &url)
{
    KArchive *kArch = nullptr;

    /*
     * This checks depends on type COMPRESSED_MIMETYPES in file fmh.h
     */
    // qDebug() << "@gadominguez File: fmstatic.cpp Func: getKArchiveObject MimeType: " << FMH::getMime(url);

    if (FMH::getMime(url).contains("application/x-tar") || FMH::getMime(url).contains("application/x-compressed-tar")) {
        kArch = new KTar(url.toString().split(QString("file://"))[1]);
    } else if (FMH::getMime(url).contains("application/zip")) {
        kArch = new KZip(url.toString().split(QString("file://"))[1]);
    } else if (FMH::getMime(url).contains("application/x-archive")) {
        kArch = new KAr(url.toString().split(QString("file://"))[1]);
    } else if (FMH::getMime(url).contains("application/x-7z-compressed")) {
#ifdef K7ZIP_H
        kArch = new K7Zip(url.toString().split(QString("file://"))[1]);
#endif
    } else {
        // qDebug() << "ERROR. COMPRESSED FILE TYPE UNKOWN " << url.toString();
    }

    return kArch;
}

void CompressedFile::setUrl(const QUrl &url)
{
    if (m_url == url)
        return;

    m_url = url;
    emit this->urlChanged();

    m_model->setUrl(m_url);
}

QUrl CompressedFile::url() const
{
    return m_url;
}

bool CompressedFile::isDecompress()
{
   return m_decompressed;
}

void CompressedFile::setDecompress(bool isDecompress)
{
    if (m_decompressed == isDecompress)
        return;
    m_decompressed = isDecompress;
    emit this->decompressChanged();
}

bool CompressedFile::isCompress()
{
    return m_compressed;
}

void CompressedFile::setCompress(bool isCompress)
{
    if (m_compressed == isCompress)
            return;
    m_compressed = isCompress;
    emit this->compressChanged();
}

CompressedFileModel *CompressedFile::model() const
{
    return m_model;
}
