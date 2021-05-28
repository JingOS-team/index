/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef LEFTMEUNMODEL_H
#define LEFTMEUNMODEL_H

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

class LeftMenuData : public QObject
{
    Q_OBJECT
    // Q_PROPERTY(QString unselectIcon READ getUnselectIcon WRITE setUnselectIcon)
    // Q_PROPERTY(bool itemChecked READ getItemChecked WRITE setItemChecked NOTIFY itemCheckedChanged)

private:
    bool isEmit;
    quint64 sizeOfResult;

public:
    explicit LeftMenuData(QObject *parent = nullptr);

    Q_INVOKABLE QString getUserName();
    Q_INVOKABLE QString getHomePath();
    Q_INVOKABLE QString getDownloadsPath();
    Q_INVOKABLE QString getRootPath();
    Q_INVOKABLE QString getTrashPath();

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
    int isTagFile(const QString url);
    void removeSth(const QString url);
    QStringList getUSBDevice();
    void killMedia();

signals:
    void removeCollection(QString folderPath);
    void addCollection(QString folderPath);
    void refreshDirSize(quint64 size);
    void refreshImageSource(QString imagePath);
    void deviceRemoved(QStringList deviceList);
    void deviceAdded(QStringList deviceList);
};

#endif
