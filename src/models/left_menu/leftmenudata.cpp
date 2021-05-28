/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: (C) 2021 Wangrui <Wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "models/left_menu/leftmenudata.h"

#include <QFile>
#include <QDebug>
#include <QDir>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "fmstatic.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/fmstatic.h>
#endif

#include <KIO/RestoreJob>
#include <KIO/CopyJob>
#include <QProcess>

#include <QtConcurrent>
#include <QFuture>

#include <kio/previewjob.h>
#include <QPixmap>

#include <QStandardPaths>
#include <solid/devicenotifier.h>
#include <solid/opticaldisc.h>
#include <solid/opticaldrive.h>
#include <solid/portablemediaplayer.h>
#include <solid/predicate.h>
#include <solid/storageaccess.h>
#include <solid/storagedrive.h>
#include <solid/storagevolume.h>

/* ~ LeftMenuData ~ */
LeftMenuData::LeftMenuData(QObject *parent) : QObject(parent)
{
	Solid::DeviceNotifier *notifier = Solid::DeviceNotifier::instance();

    connect(notifier, &Solid::DeviceNotifier::deviceAdded, [this](const QString &device) {
		emit this->deviceAdded(getUSBDevice());
     });

     connect(notifier, &Solid::DeviceNotifier::deviceRemoved, [this](const QString &device) {
		emit this->deviceRemoved(getUSBDevice());
     });
}

QStringList LeftMenuData::getUSBDevice()
{
	QTime dieTime = QTime::currentTime().addMSecs(500);//拿到通知以后 如果马上去获取的话 并没有挂载成功 所以需要等待500ms
	while( QTime::currentTime() < dieTime )
	{
		QCoreApplication::processEvents(QEventLoop::AllEvents, 100);
	}

	QStringList res;
	QString usbPath = "/media/jingos";
	QDir tmpDir(usbPath);
	foreach(QString subDir, tmpDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
    {
		QString usbDir = "file://" + usbPath + QDir::separator() + subDir;
		res << usbDir;
    }
	return res;
}


QString LeftMenuData::getUserName()
{
	int index = FMH::HomePath.lastIndexOf("/");
	QString userName = FMH::HomePath.mid(index + 1);
	return userName;
}
    
QString LeftMenuData::getHomePath()
{
	return FMH::HomePath;
}

QString LeftMenuData::getDownloadsPath()
{
	return FMH::DownloadsPath;
}

QString LeftMenuData::getRootPath()
{
	return FMH::RootPath;
}

QString LeftMenuData::getTrashPath()
{
	return FMH::TrashPath;
}

void LeftMenuData::restoreFromTrash(const QList<QUrl> &urls)
{
	auto job = KIO::restoreFromTrash(urls, KIO::HideProgressInfo);
	job->start();	
}

QString LeftMenuData::createDir(const QUrl &path, const QString &name)
{
	QString dir_str = path.toString() + "/" + name;
	dir_str.replace(QString("file://"), QString(""));
	QDir dir;
	QString folderName = dir_str;
	int count = 1;
	while(dir.exists(folderName))
	{
		if(count == 10)
		{
			folderName = path.toString() + "/" + "Are U Crazy?";
			folderName.replace(QString("file://"), QString(""));
		}else
		{
			folderName = dir_str + QString::number(count);
		}
		count++;
	}
	dir.mkpath(folderName);
	return "file://" + folderName;
}

bool LeftMenuData::playVideo(const QString url)
{
	addFileToRecents(url);
    QString kill = "killall -9 haruna";
    QProcess process(this);
    process.execute(kill);
    QStringList arguments;//用于传参数
    QString program = "/usr/bin/haruna";
    arguments << QString::number(0);
    arguments << QString::number(0);
    arguments << url;
    process.startDetached(program, arguments);
    return true;
}

void LeftMenuData::addFileToRecents(const QString url)
{
	if(!FMStatic::urlTagExists(url, "recents_jingos"))
	{
		FMStatic::addTagToUrl("recents_jingos", url);
	}
}

void LeftMenuData::addFolderToCollection(const QString url, const bool justRemove, const bool needRefresh)
{
	if(FMStatic::urlTagExists(url, "collection_jingos"))
	{
		FMStatic::removeTagToUrl("collection_jingos", url);//删除
		if(needRefresh)
		{
			emit this->removeCollection(url);
		}
	}else if(!justRemove)
	{
		FMStatic::addTagToUrl("collection_jingos", url);//增加
		if(needRefresh)
		{
			emit this->addCollection(url);
		}
		
	}
}

bool LeftMenuData::isCollectionFolder(const QString url)
{
	if(FMStatic::urlTagExists(url, "collection_jingos"))
	{
		return true;
	}else
	{
		return false;
	}
}

QVariantList LeftMenuData::getCollectionList()
{
	QVariantList res;
	FMH::MODEL_LIST collectionList = FMStatic::getTagContent("collection_jingos");
	//排序start
	std::sort(collectionList.begin(), collectionList.end(), [](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool {

                const auto str1 = QString(e1[FMH::MODEL_KEY::LABEL]).toLower();
                const auto str2 = QString(e2[FMH::MODEL_KEY::LABEL]).toLower();

                // if(sortOrder == Qt::AscendingOrder)
                // {
                     if (str1 < str2)
                    {
                        return true;
                    }
                // }else
                // {
                //      if (str1 > str2)
                //     {
                //         return true;
                //     }
                // }
				return false;
        });
	//排序end


	for(const auto &item : collectionList)
	{
		res << FMH::toMap(item);
	}
	return res;
}

quint64 LeftMenuData::getDirSizeReal(const QString &filePath)
{
    QDir tmpDir(filePath);
    quint64 size = 0;

    /*获取文件列表  统计文件大小*/
    foreach(QFileInfo fileInfo, tmpDir.entryInfoList(QDir::Files))
    {
        size += fileInfo.size();
		if(!this->isEmit)
		{
			break;
		}
    }

    /*获取文件夹  并且过滤掉.和..文件夹 统计各个文件夹的文件大小 */
    foreach(QString subDir, tmpDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
    {
        size += getDirSizeReal(filePath + QDir::separator() + subDir); //递归进行  统计所有子目录
		sizeOfResult += size;
		if(!this->isEmit)
		{
			break;
		}
		if(sizeOfResult > 0)
		{
			emit this->refreshDirSize(sizeOfResult);
		}
    }
    return size;
}


void LeftMenuData::getDirSize(const QString &filePath)
{
	this->isEmit = true;
	sizeOfResult = 0;
	QFutureWatcher<quint64> *watcher = new QFutureWatcher<quint64>;
    connect(watcher, &QFutureWatcher<quint64>::finished, [&, watcher]()
    {
		if(this->isEmit)
		{
			emit this->refreshDirSize(watcher->future().result());
		}
        watcher->deleteLater();
    });

    const auto func = [=]() -> quint64
    {
		quint64 size = getDirSizeReal(filePath);
		return size;
    };

    QFuture<quint64> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);
}

void LeftMenuData::cancelGetDirSize()
{
	this->isEmit = false;
}

QString LeftMenuData::getVideoPreview(const QUrl &url)
{
	auto path = url.toString();
	int index = path.lastIndexOf(".");
	QString newPath = path.mid(0, index);//path/name
	index = newPath.lastIndexOf("/");
	QString startPath = newPath.mid(0, index + 1);//path/
	QString endPath = newPath.mid(index + 1, newPath.length());//name
	path = startPath + "." + endPath + ".jpg";

	QFutureWatcher<quint64> *watcher = new QFutureWatcher<quint64>;
    connect(watcher, &QFutureWatcher<quint64>::finished, [&, watcher]()
    {
        watcher->deleteLater();
    });

    const auto func = [=]() -> quint64
    {
		QFile file(path.mid(7));
		if(file.exists())
		{
			return -1;
		}

		QStringList plugins;
		plugins << KIO::PreviewJob::availablePlugins();
		KFileItemList list;
		list.append(KFileItem(url, QString(), 0));
		KIO::PreviewJob *job = KIO::filePreview(list, QSize(256, 256), &plugins);
		job->setIgnoreMaximumSize(true);
		job->setScaleType(KIO::PreviewJob::ScaleType::Unscaled);
		
		QObject::connect(job, &KIO::PreviewJob::gotPreview, [=] (const KFileItem &item, const QPixmap &preview) {
			preview.save(path.mid(7), "JPG");
			emit this->refreshImageSource(path);
		});
		QObject::connect(job, &KIO::PreviewJob::failed, [=] (const KFileItem &item) {
		});
		job->exec();
		return 0;
    };

    QFuture<quint64> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);

	return path;
}

const FMH::MODEL LeftMenuData::getFileInfoModel(const QUrl &path)
{
	FMH::MODEL model = FMH::getFileInfoModel(path);
	return model;
}

void LeftMenuData::addToTag(const QString url, const int index, const bool justAdd)//批量打tag的时候，会出现有tag和没有tag的文件都被认为是需要重新打tag。所以不进行移除
{
	//每个文件有且只有一个tag0--7之间的tag，在添加新的tag时，如果有旧的，则进行移除
	int tagIndex = isTagFile(url);
	if(tagIndex != -1 && tagIndex != index)
	{
		QString tag = "tag" + QString::number(tagIndex) + "_jingos";
		FMStatic::removeTagToUrl(tag, url);//删除
	}

	QString tag = "tag" + QString::number(index) + "_jingos";
	if(FMStatic::urlTagExists(url, tag))
	{
		if(!justAdd)
		{
			FMStatic::removeTagToUrl(tag, url);//删除
		}
	}else
	{
		FMStatic::addTagToUrl(tag, url);//增加
	}
}

int LeftMenuData::isTagFile(const QString url)
{
	int index = -1;
	for(int i = 0; i < 8; i++)
	{
		QString tag = "tag" + QString::number(i) + "_jingos";
		if(FMStatic::urlTagExists(url, tag))
		{
			index = i;
			break;
		}
	}
	return index;
}

void LeftMenuData::removeSth(const QString url)
{
	QProcess wtfProcess(this);
	QString tmp = url;
	tmp = "rm -rf " + tmp.replace(QString("file://"), QString(""));
    wtfProcess.execute(tmp);
}

void LeftMenuData::killMedia()
{
    QString kill = "killall -9 media";
    QProcess process(this);
    process.execute(kill);
}