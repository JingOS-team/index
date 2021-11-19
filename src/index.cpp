// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//           2021      Zhang He Gang <zhanghegang@jingos.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "index.h"

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include "ktoolinvocation.h"
#endif

#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QUrl>

Index::Index(QObject *parent)
    : QObject(parent)
{
}

Index::Index(JApplicationQt *japp)
    : m_japp(japp)
{
}

/* to be called to launch index with opening different paths */
void Index::openPaths(const QStringList &paths)
{
    emit this->openPath(std::accumulate(paths.constBegin(), paths.constEnd(), QStringList(), [](QStringList &list, const QString &path) -> QStringList {
        auto url = QUrl::fromUserInput(path);
        if (url.isLocalFile()) {
            const QFileInfo file(url.toLocalFile());
            if (file.isDir()){
                QString urlStr =  url.toString();
                bool isEnd = urlStr.endsWith("/.");
                if(isEnd){
                    list << urlStr.left(urlStr.length() - 2);
                }else {
                    list << url.toString();
                }
            } else{
                list << QUrl::fromLocalFile(file.dir().absolutePath()).toString();
            }
        } else
            list << url.toString();

        return list;
    }));
}

void Index::openTerminal(const QUrl &url)
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    if (url.isLocalFile()) {
        KToolInvocation::invokeTerminal(QString(), url.toLocalFile());
        return;
    }

    // Nothing worked, just use $HOME
    KToolInvocation::invokeTerminal(QString(), QDir::homePath());
#else
    Q_UNUSED(url)
#endif
}

void Index::setEnableBackground(bool enable)
{
    // if(m_japp){
    //     m_japp -> enableBackgroud(enable);
    // }
}
