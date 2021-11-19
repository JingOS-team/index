/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

#ifndef LEFTMEUNMODEL_H
#define LEFTMEUNMODEL_H
#include <QDebug>

#include <QObject>
#include <QFile>
#include <QDateTime>
#include <QScreen>
#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "fmstatic.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/fmstatic.h>
#endif
#include <solid/predicate.h>
#include <solid/storageaccess.h>
#include <Solid/Device>
#include <QTimer>
#include <KLocalizedString>
#include <KLocalizedContext>
#include <kio/previewjob.h>

class LeftMenuData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString defaultDesktop READ defaultDesktop NOTIFY defaultChanged)
    Q_PROPERTY(QString defaultDocument READ defaultDocument NOTIFY defaultChanged)
    Q_PROPERTY(QString defaultPicture READ defaultPicture NOTIFY defaultChanged)
    Q_PROPERTY(QString defaultMusic READ defaultMusic NOTIFY defaultChanged)
    Q_PROPERTY(QString defaultVideo READ defaultVideo NOTIFY defaultChanged)
    Q_PROPERTY(QString defaultDownloads READ defaultDownloads NOTIFY defaultChanged)

public:
    explicit LeftMenuData(QObject *parent = nullptr);

    Q_INVOKABLE QString getUserName();
    Q_INVOKABLE QString getHomePath();
    Q_INVOKABLE QString getDownloadsPath();
    Q_INVOKABLE QString getRootPath();
    Q_INVOKABLE QString getTrashPath();
    Q_INVOKABLE void ejectDevice(QString path);
    Q_INVOKABLE bool supportEjectDevice(QString path);
    Q_INVOKABLE void moveToTrash(const QList<QUrl> &urls);
    void requestGetUsbDevice(bool isAdd);
    bool isDeviceValid(QString path);

    QString defaultDesktop() {
        return FMH::DesktopPath;
    }
    QString defaultDocument() {

        return FMH::DocumentsPath;
    }
    QString defaultPicture() {
        return FMH::PicturesPath;
    }
    QString defaultMusic() {
        return FMH::MusicPath;
    }
    QString defaultVideo() {
        return FMH::VideosPath;
    }
    QString defaultDownloads() {
        return FMH::DownloadsPath;
    }

public slots:	
    void restoreFromTrash(const QList<QUrl> &urls);
    QString createDir(const QUrl &path, const QString &name);
    bool playVideo(const QString url);
    // FMH::MODEL_LIST getList(const int type);
    void addFileToRecents(const QString url);
    void addFolderToCollection(const QString url, const bool justRemove, const bool needRefresh);
    bool isCollectionFolder(const QString url);
    void getDirSize(const QString &filePath);
    quint64 getDirSizeReal(const QString &filePath);
    void cancelGetDirSize();
    QString getVideoPreview(const QUrl &url);
    const FMH::MODEL getFileInfoModel(const QUrl &path);
    QVariantList getCollectionList();
    void addToTag(const QString url, const int index, const bool justAdd);
    void removeToTags(const QList<QString> &urls, const int index);
    void addToTags(const QList<QString> &urls, const int index);
    int isTagFile(const QString url);
    void updateTagUrl();
    void removeSth(const QString url);
    QStringList getUSBDevice(bool isFirst);
    void killMedia();
    bool is24HourFormat();
    void slotStorageTearDownDone(Solid::ErrorType error, const QVariant& errorData);
    void slotLayoutTimerFinished();
    bool isDefaultFile(QString path);

signals:
    void removeCollection(QString folderPath);
    void addCollection(QString folderPath);
    void refreshDirSize(quint64 size);
    void refreshImageSource(QString imagePath);
    void deviceRemoved(QStringList deviceList);
    void deviceAdded(QStringList deviceList);
    void tipMessage(QString tipInfo);
    void dialogMessage(QString dialogContent);
    void defaultChanged();
    void trashFinishChaned(bool success);


private:
    bool isEmit;
    quint64 sizeOfResult;
    bool isAddUsbDevice;
    QTimer *m_getUsbTimer;
    const QStringList plugins = KIO::PreviewJob::availablePlugins();
    QHash<QString,QString> m_defaultPaths = {{FMH::DesktopPath,"default"},
                                             {FMH::DocumentsPath,"default"},
                                             {FMH::PicturesPath,"default"},
                                             {FMH::MusicPath,"default"},
                                             {FMH::VideosPath,"default"},
                                             {FMH::DownloadsPath,"default"}
                                            };

};

#endif
