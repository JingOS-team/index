/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
#ifndef FILEPREVIEWER_H
#define FILEPREVIEWER_H

#include <QObject>

class FilePreviewer : public QObject
{
    Q_OBJECT
public:
    explicit FilePreviewer(QObject *parent = nullptr);

signals:
};

#endif // FILEPREVIEWER_H
