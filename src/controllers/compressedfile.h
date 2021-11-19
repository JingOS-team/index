/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
#ifndef COMPRESSEDFILE_H
#define COMPRESSEDFILE_H

#include <QObject>

#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>

class KArchive;
class CompressedFileModel : public MauiList
{
    Q_OBJECT
public:
    explicit CompressedFileModel(QObject *parent);
    const FMH::MODEL_LIST &items() const override final;

    void setUrl(const QUrl &url);

private:
    FMH::MODEL_LIST m_list;
};

class CompressedFile : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(bool isDecompress READ isDecompress NOTIFY decompressChanged)
    Q_PROPERTY(bool isCompress READ isCompress NOTIFY compressChanged)
    Q_PROPERTY(CompressedFileModel *model READ model CONSTANT FINAL)

public:
    explicit CompressedFile(QObject *parent = nullptr);
    static KArchive *getKArchiveObject(const QUrl &url);

    void setUrl(const QUrl &url);
    QUrl url() const;
    bool isDecompress();
    void setDecompress(bool isDecompress);
    bool isCompress();
    void setCompress(bool isCompress);

    CompressedFileModel *model() const;

    QString checkFileName(const QUrl &where, const QString &fileName, const bool isExtract);

private:
    QUrl m_url;
    CompressedFileModel *m_model;
    bool m_decompressed = false;
    bool m_compressed = false;

public slots:
    void extract(const QUrl &where, const QString &directory = QString());
    bool compress(const QVariantList &files, const QUrl &where, const QString &fileName, const int &compressTypeSelected);

    void extractWithThread(const QUrl &where, const QString &directory = QString(),const QUrl &archUrl = QString());
    bool compressWithThread(const QVariantList &files, const QUrl &where, const QString &fileName, const int &compressTypeSelected);

signals:
    void urlChanged();
    void finishZip(QString filePath);
    void startZip(QString filePath);
    void decompressChanged();
    void compressChanged();
    void tipMessage(QString messageType);
};

#endif // COMPRESSEDFILE_H
