/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

#include "leftmenudata.h"

#include <QFile>
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

#include <QPixmap>

#include <QStandardPaths>
#include <solid/devicenotifier.h>
#include <solid/opticaldisc.h>
#include <solid/opticaldrive.h>
#include <solid/portablemediaplayer.h>

#include <solid/storagedrive.h>
#include <solid/storagevolume.h>
#include <KConfigGroup>
#include <KSharedConfig>
#include <QUrl>

/* ~ LeftMenuData ~ */
LeftMenuData::LeftMenuData(QObject *parent) : QObject(parent)
{
	m_getUsbTimer = new QTimer(this);
    m_getUsbTimer->setInterval(500);
	m_getUsbTimer->setSingleShot(true);
    connect(m_getUsbTimer, &QTimer::timeout, this, &LeftMenuData::slotLayoutTimerFinished);
	Solid::DeviceNotifier *notifier = Solid::DeviceNotifier::instance();

    connect(notifier, &Solid::DeviceNotifier::deviceAdded, [this](const QString &device) {
    	Solid::Device deviceItem(device);
        if (deviceItem.isDeviceInterface(Solid::DeviceInterface::StorageDrive)){
			requestGetUsbDevice(true);
		}
     });

     connect(notifier, &Solid::DeviceNotifier::deviceRemoved, [this](const QString &device) {
		 	requestGetUsbDevice(false);	   
     });
}
void LeftMenuData::requestGetUsbDevice(bool isAdd)
{
	isAddUsbDevice = isAdd;
	if (m_getUsbTimer->isActive()) {
		m_getUsbTimer->stop();
	}
	m_getUsbTimer->start();	
}

void LeftMenuData::slotLayoutTimerFinished()
{
	if (isAddUsbDevice) {
    	emit this->deviceAdded(getUSBDevice(false));
	} else {
		emit this->deviceRemoved(getUSBDevice(false));
	}
}

bool LeftMenuData::supportEjectDevice(QString path)
{
    qDebug()<< Q_FUNC_INFO << " DEVICE PATH:" << path;
	
	if (isDeviceValid(path)) {
		return true;
	}

    if (path.startsWith("file://")) {
        path = path.mid(7);
	}
    QString udiStr = path;
    Solid::Device device = Solid::Device::storageAccessFromPath(udiStr);
	Solid::StorageDrive* drive = device.as<Solid::StorageDrive>();
    if (!drive) {
        drive = device.parent().as<Solid::StorageDrive>();
    }

    bool hotPluggable = false;
    bool removable = false;
    if (drive) {
        hotPluggable = drive->isHotpluggable();
        removable = drive->isRemovable();
    }
	return removable || hotPluggable;
}

bool LeftMenuData::isDeviceValid(QString path)
{
	if (path.startsWith("file://")) {
			path = path.mid(7);
		}
    QString udiStr = path;
    Solid::Device device = Solid::Device::storageAccessFromPath(udiStr);
	bool isDeviceValid = device.isValid();
    qDebug()<< Q_FUNC_INFO << " DEVICE VAILD:" << isDeviceValid;
	return isDeviceValid;
}

void LeftMenuData::ejectDevice(QString path)
{
    qDebug()<< Q_FUNC_INFO << " EJECT PATH:" << path;

    if (path.startsWith("file://")) {
        path = path.mid(7);
	}
    QString udiStr = path;
    Solid::Device deviceItem = Solid::Device::storageAccessFromPath(udiStr);
	if (deviceItem.is<Solid::OpticalDisc>()) {
		Solid::OpticalDrive *drive = deviceItem.as<Solid::OpticalDrive>();
        if (!drive) {
			drive = deviceItem.parent().as<Solid::OpticalDrive>();
		}
		if (drive) {
			connect(drive, &Solid::OpticalDrive::ejectDone,
						this, &LeftMenuData::slotStorageTearDownDone);
			drive->eject();
		}
	}  else if (deviceItem.is<Solid::StorageAccess>()) {
		Solid::StorageAccess *access = deviceItem.as<Solid::StorageAccess>();
		if (access && access->isAccessible()) {
			connect(access, &Solid::StorageAccess::teardownDone ,
						this, &LeftMenuData::slotStorageTearDownDone);
			access->teardown();
		}
	}
}

void LeftMenuData::slotStorageTearDownDone(Solid::ErrorType error, const QVariant& errorData)
{
    qWarning()<< Q_FUNC_INFO << " ERRORDATA " << errorData << " error:" << error;
	if (error && errorData.isValid()) {
		//fail
		emit this->tipMessage(i18n("USB device eject fail"));
	} else {
		//suc
		requestGetUsbDevice(false);
		emit this->tipMessage(i18n("USB device eject success"));
	}
}

QStringList LeftMenuData::getUSBDevice(bool isFirst)
{
    QStringList res;
    QString usbPath = "/media/" + getUserName();
    QDir tmpDir(usbPath);
    foreach(QString subDir, tmpDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
    {
        QString usbDir = "file://" + usbPath + QDir::separator() + subDir;
		bool isValid = isDeviceValid(usbDir);
		if (!isValid) {
			continue;
		}
        res << usbDir;
    }
    return res;
}

bool LeftMenuData::isDefaultFile(QString path)
{
    return m_defaultPaths.contains(path);
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
    QString downloadPath = FMH::DownloadsPath;
    if (downloadPath.startsWith("file://")) {
       downloadPath = downloadPath.mid(7);
    }
    QDir downloadDir(downloadPath);
    bool isExists = downloadDir.exists();
    if(!isExists){
        bool isMkPath = downloadDir.mkpath(downloadPath);
    }
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
	QObject::connect(job, &KJob::result, [=] (KJob *job) {
		if (job->error()) {
			QString errorContent = job->errorString();
			emit this->dialogMessage(errorContent);
        } else {
            emit this->trashFinishChaned(true);
        }
    });
    job->exec();
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
        folderName = dir_str + QString::number(count);
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
        FMStatic::removeTagToUrl("collection_jingos", url);
		if(needRefresh)
		{
			emit this->removeCollection(url);
		}
	}else if(!justRemove)
	{
        FMStatic::addTagToUrl("collection_jingos", url);
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
    std::sort(collectionList.begin(), collectionList.end(), [](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool {

        const auto str1 = QString(e1[FMH::MODEL_KEY::LABEL]).toLower();
        const auto str2 = QString(e2[FMH::MODEL_KEY::LABEL]).toLower();
        if (str1 < str2)
        {
            return true;
        }
        return false;
    });

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

    foreach(QFileInfo fileInfo, tmpDir.entryInfoList(QDir::Files))
    {
        size += fileInfo.size();
		if(!this->isEmit)
		{
			break;
		}
    }

    foreach(QString subDir, tmpDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot))
    {
        size += getDirSizeReal(filePath + QDir::separator() + subDir);
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
    QString newPath = path.mid(0, index);
	index = newPath.lastIndexOf("/");
    QString startPath = newPath.mid(0, index + 1);
    QString endPath = newPath.mid(index + 1, newPath.length());
	path = startPath + "." + endPath + ".jpg";
    QFile file(path.mid(7));
    if(file.exists())
    {
        return path;
    }
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

        KFileItemList list;
        list.append(KFileItem(url, QString(), 0));
        KIO::PreviewJob *job = KIO::filePreview(list, QSize(256, 256),&plugins);
        job->setIgnoreMaximumSize(true);
        job->setScaleType(KIO::PreviewJob::ScaleType::Unscaled);
		
        QObject::connect(job, &KIO::PreviewJob::gotPreview, [=] (const KFileItem &item, const QPixmap &preview) {
            qDebug()<<Q_FUNC_INFO << " gotPreview:" << path;
            preview.save(path.mid(7), "JPG");
            emit this->refreshImageSource(path);
        });
        QObject::connect(job, &KIO::PreviewJob::failed, [=] (const KFileItem &item) {
             qDebug()<<Q_FUNC_INFO << " failed:";
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

void LeftMenuData::addToTag(const QString url, const int index, const bool justAdd)
{
	int tagIndex = isTagFile(url);
    if(tagIndex != -1 && tagIndex != index) {
		QString tag = "tag" + QString::number(tagIndex) + "_jingos";
        FMStatic::removeTagToUrl(tag, url);
	}

	QString tag = "tag" + QString::number(index) + "_jingos";
	if(FMStatic::urlTagExists(url, tag))
	{
		if(!justAdd)
		{
            FMStatic::removeTagToUrl(tag, url);
		}
    } else {
        FMStatic::addTagToUrl(tag, url);
	}
}

void LeftMenuData::addToTags(const QList<QString> &urls, const int index)
{
    const QString tag = "tag" + QString::number(index) + "_jingos";
    removeToTags(urls,index);
    FMStatic::addTags(tag, urls);
}

void LeftMenuData::removeToTags(const QList<QString> &urls, const int index)
{
    QString tag = "tag" + QString::number(index) + "_jingos";
    FMStatic::removeTags(tag, urls);
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

void LeftMenuData::updateTagUrl()
{
    FMStatic::updateTagUrl();
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

bool LeftMenuData::is24HourFormat()
{
    KSharedConfig::Ptr  m_localeConfig = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
    KConfigGroup m_localeSettings = KConfigGroup(m_localeConfig, "Locale");

    QString timeFormat = m_localeSettings.readEntry("TimeFormat", QStringLiteral("FORMAT24H"));
    return (timeFormat.lastIndexOf("ap") == -1) ;
}

void LeftMenuData::moveToTrash(const QList<QUrl> &urls)
{
    auto job = KIO::trash(urls);
    QObject::connect(job, &KJob::result, [=] (KJob *job) {
        if (job->error()) {
            QString errorContent = job->errorString();
            emit this->tipMessage(errorContent);
        }
    });
    job->start();
}
