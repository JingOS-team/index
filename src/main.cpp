// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
// Copyright 2021 Zhang He Gang <zhanghegang@jingos.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
// #include <QQmlContext>

#include <KAboutData>

#include "index.h"

#ifdef Q_OS_ANDROID
#include "mauiandroid.h"
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#ifdef Q_OS_MACOS
#include "mauimacos.h"
#endif

#include <MauiKit/mauiapp.h>

// #if defined Q_OS_MACOS || defined Q_OS_WIN
// #include <KF5/KI18n/KLocalizedString>
// #else
// #include <KI18n/KLocalizedString>
// #endif

#include "../index_version.h"

#include "controllers/compressedfile.h"
#include "controllers/filepreviewer.h"

#include "models/left_menu/leftmenudata.h"
#include "models/ProcessModel.h"

#include <KLocalizedString>
#include <KLocalizedContext>

#include <QtQml>
#include <QDateTime>
#include <KDBusService>

#include <japplicationqt.h>

#define INDEX_URI "org.maui.index"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qint64 startTime = QDateTime::currentMSecsSinceEpoch();
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

#ifdef Q_OS_WIN32
    qputenv("QT_MULTIMEDIA_PREFERRED_PLUGINS", "w");
#endif

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif
    JApplicationQt japp;
    japp.enableBackgroud(true);
    bool backgroundStartUp = qEnvironmentVariableIsSet("BACKGROUNDSTARTUP");
    QApplication::setQuitLockEnabled(!backgroundStartUp);
    QObject::connect(&japp, &JApplicationQt::resume, [&backgroundStartUp]() {
        backgroundStartUp = false;
    });
    KLocalizedString::setApplicationDomain("filemanager");
    KLocalizedString::addDomainLocaleDir("filemanager", "/usr/share/local");

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/zip.png"));
    
    MauiApp::instance()->setHandleAccounts(false); // for now index can not handle cloud accounts
    MauiApp::instance()->setIconName("qrc:/assets/index_new.svg");

    KAboutData about(QStringLiteral("index"), i18n("Index"), INDEX_VERSION_STRING, i18n("Index allows you to navigate your computer and preview multimedia files."), KAboutLicense::LGPL_V3, i18n("© 2019-2020 Nitrux Development Team"));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.addAuthor(i18n("Gabriel Dominguez"), i18n("Developer"), QStringLiteral("gabriel@gabrieldominguez.es"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/index");
    about.setBugAddress("https://invent.kde.org/maui/index-fm/-/issues");
    about.setOrganizationDomain("kde.org");
    about.setProgramLogo(app.windowIcon());
    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    KDBusService* service = new KDBusService(KDBusService::Unique | KDBusService::Replace, &app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);

    const QStringList args = parser.positionalArguments();
    QStringList paths;

    if (!args.isEmpty())
    {
        paths = args;
    }
        
    Index index(&japp);
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url, paths, &index](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
            if (!paths.isEmpty())
                index.openPaths(paths);
        },
        Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("inx", &index);
    engine.rootContext()->setContextProperty("japp", &japp);
    engine.rootContext()->setContextProperty("realVisible", !backgroundStartUp);
    QObject::connect(&japp, &JApplicationQt::resume, [&engine]() {
        engine.rootContext()->setContextProperty("realVisible", true);
    });
    qmlRegisterSingletonType<ProcessModel>(INDEX_URI, 1, 0, "ProcessModel", [] (QQmlEngine *, QJSEngine *) -> QObject* {
        return ProcessModel::instance();
    });
    qmlRegisterType<CompressedFile>(INDEX_URI, 1, 0, "CompressedFile");
    qmlRegisterType<FilePreviewer>(INDEX_URI, 1, 0, "FilePreviewProvider");
    qmlRegisterType<LeftMenuData>(INDEX_URI, 1, 0, "LeftMenuData");
    engine.rootContext()->setContextProperty("MainStartTime",startTime);

    KLocalizedContext *kc = new KLocalizedContext(&engine);
    kc->setTranslationDomain("filemanager");
    engine.rootContext()->setContextObject(kc);
    engine.load(url);
    qint64 endTime = QDateTime::currentMSecsSinceEpoch();

    FMStatic::updateTagUrl();

#ifdef Q_OS_MACOS
//        MAUIMacOS::removeTitlebarFromWindow();
//        MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif
    return app.exec();
}

