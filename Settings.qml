pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool debug: Quickshell.env("ASTRALITH_DEBUG") === "1"
    property bool compact: false
    property bool textIcons: false
    property bool motion: true
    property bool animateStars: true
    property string atmosphereStyle: "nominal"
    property bool adaptivePalette: false
    property string motionStyle: "rise"
    property string accentName: "violet"
    property string typographyProfile: "serpantinum"
    property string fontText: "JetBrains Mono"
    property string fontDisplay: "JetBrains Mono"
    property string fontMono: "JetBrains Mono"
    property string fontIcon: "Iosevka Nerd Font"
    property string barMode: "capsules"
    property int barMargin: 12
    property real barOpacity: 0.94
    property bool quickActionsEnabled: true
    property string quickActionsEdge: "right"
    property bool umbraMotion: true
    property bool umbraUseWallpaper: true
    property bool umbraBlurWallpaper: true
    property bool umbraShowMedia: true
    property bool umbraShowWeather: true
    property string umbraPamService: "login"

    property bool showLauncherButton: true
    property bool showSettingsButton: true
    property bool showWorkspaces: true
    property bool showFocusedWindow: true
    property bool showSystemStats: true
    property bool showAudio: true
    property bool showMedia: true
    property bool showMediaProgress: true
    property bool showMediaTime: true
    property bool showTray: true
    property bool showNetworkLabel: true
    property bool showBluetooth: true
    property bool showBrightness: true
    property bool showBattery: true
    property bool showMicrophone: true
    property bool showSeconds: true
    property bool showDate: true
    property bool doNotDisturb: false

    property int launcherMaxResults: 80
    property bool showLauncherHints: true
    property bool showAppDescriptions: true
    property int wallpaperColumns: 3
    property string wallpaperPath: ""
    property string wallpaperKind: "image"
    property string wallpaperOutputs: "all"
    property string wallpaperTransition: "any"
    property bool weatherEnabled: true
    property string weatherLocation: "Oslo, Norway"
    property string temperatureUnit: "celsius"

    property string terminal: "terminology"
    property string browser: "firefox"
    property string fileManager: "nautilus"

    readonly property string clockFormat: showSeconds ? "HH:mm:ss" : "HH:mm"
    property string dateFormat: "yyyy · MM · dd"
    readonly property string configRoot: {
        const xdg = Quickshell.env("XDG_CONFIG_HOME") || "";
        const home = Quickshell.env("HOME") || "/tmp";
        return (xdg.length > 0 ? xdg : home + "/.config")
            + "/astralith";
    }
    readonly property string configPath: configRoot + "/settings.json"

    property bool applying: false
    property bool persistenceReady: false

    function queueSave() {
        if (persistenceReady && !applying)
            saveTimer.restart();
    }

    function applyBarPreset(name) {
        if (name === "minimal") {
            showSystemStats = false;
            showNetworkLabel = false;
            showBluetooth = false;
            showBrightness = false;
            showBattery = true;
            showMicrophone = false;
            showTray = false;
            showDate = false;
        } else if (name === "telemetry") {
            showSystemStats = true;
            showNetworkLabel = true;
            showBluetooth = true;
            showBrightness = true;
            showBattery = true;
            showMicrophone = true;
            showTray = true;
            showDate = true;
        } else {
            showSystemStats = true;
            showNetworkLabel = true;
            showBluetooth = true;
            showBrightness = false;
            showBattery = true;
            showMicrophone = true;
            showTray = true;
            showDate = true;
        }
    }

    function applyTypographyPreset(name) {
        typographyProfile = name;
        if (name === "readable") {
            fontText = "Noto Sans";
            fontDisplay = "JetBrains Mono";
            fontMono = "JetBrains Mono";
            fontIcon = "Iosevka Nerd Font";
        } else if (name === "system") {
            fontText = "sans-serif";
            fontDisplay = "sans-serif";
            fontMono = "monospace";
            fontIcon = "Iosevka Nerd Font";
        } else {
            // Serpantinum's visual voice is overwhelmingly JetBrains Mono,
            // with Iosevka Nerd Font reserved for symbolic glyphs.
            fontText = "JetBrains Mono";
            fontDisplay = "JetBrains Mono";
            fontMono = "JetBrains Mono";
            fontIcon = "Iosevka Nerd Font";
        }
    }

    function applyFromDisk() {
        applying = true;
        compact = settingsFile.compact;
        textIcons = settingsFile.textIcons;
        motion = settingsFile.motion;
        animateStars = settingsFile.animateStars;
        atmosphereStyle = settingsFile.atmosphereStyle || "nominal";
        adaptivePalette = settingsFile.adaptivePalette;
        motionStyle = settingsFile.motionStyle;
        accentName = settingsFile.accentName;
        typographyProfile = settingsFile.typographyProfile;
        fontText = settingsFile.fontText;
        fontDisplay = settingsFile.fontDisplay;
        fontMono = settingsFile.fontMono;
        fontIcon = settingsFile.fontIcon;
        barMode = settingsFile.barMode;
        barMargin = settingsFile.barMargin;
        barOpacity = settingsFile.barOpacity;
        quickActionsEnabled = settingsFile.quickActionsEnabled;
        quickActionsEdge = settingsFile.quickActionsEdge;
        umbraMotion = settingsFile.umbraMotion;
        umbraUseWallpaper = settingsFile.umbraUseWallpaper;
        umbraBlurWallpaper = settingsFile.umbraBlurWallpaper;
        umbraShowMedia = settingsFile.umbraShowMedia;
        umbraShowWeather = settingsFile.umbraShowWeather;
        umbraPamService = settingsFile.umbraPamService || "login";
        showLauncherButton = settingsFile.showLauncherButton;
        showSettingsButton = settingsFile.showSettingsButton;
        showWorkspaces = settingsFile.showWorkspaces;
        showFocusedWindow = settingsFile.showFocusedWindow;
        showSystemStats = settingsFile.showSystemStats;
        showAudio = settingsFile.showAudio;
        showMedia = settingsFile.showMedia;
        showMediaProgress = settingsFile.showMediaProgress;
        showMediaTime = settingsFile.showMediaTime;
        showTray = settingsFile.showTray;
        showNetworkLabel = settingsFile.showNetworkLabel;
        showBluetooth = settingsFile.showBluetooth;
        showBrightness = settingsFile.showBrightness;
        showBattery = settingsFile.showBattery;
        showMicrophone = settingsFile.showMicrophone;
        showSeconds = settingsFile.showSeconds;
        showDate = settingsFile.showDate;
        doNotDisturb = settingsFile.doNotDisturb;
        launcherMaxResults = settingsFile.launcherMaxResults;
        showLauncherHints = settingsFile.showLauncherHints;
        showAppDescriptions = settingsFile.showAppDescriptions;
        wallpaperColumns = settingsFile.wallpaperColumns;
        wallpaperPath = settingsFile.wallpaperPath;
        wallpaperKind = settingsFile.wallpaperKind;
        wallpaperOutputs = settingsFile.wallpaperOutputs;
        wallpaperTransition = settingsFile.wallpaperTransition;
        weatherEnabled = settingsFile.weatherEnabled;
        weatherLocation = settingsFile.weatherLocation;
        temperatureUnit = settingsFile.temperatureUnit;
        terminal = settingsFile.terminal;
        browser = settingsFile.browser;
        fileManager = settingsFile.fileManager;
        dateFormat = settingsFile.dateFormat;
        applying = false;
        persistenceReady = true;
    }

    function saveNow() {
        settingsFile.compact = compact;
        settingsFile.textIcons = textIcons;
        settingsFile.motion = motion;
        settingsFile.animateStars = animateStars;
        settingsFile.atmosphereStyle = atmosphereStyle;
        settingsFile.adaptivePalette = adaptivePalette;
        settingsFile.motionStyle = motionStyle;
        settingsFile.accentName = accentName;
        settingsFile.typographyProfile = typographyProfile;
        settingsFile.fontText = fontText;
        settingsFile.fontDisplay = fontDisplay;
        settingsFile.fontMono = fontMono;
        settingsFile.fontIcon = fontIcon;
        settingsFile.barMode = barMode;
        settingsFile.barMargin = barMargin;
        settingsFile.barOpacity = barOpacity;
        settingsFile.quickActionsEnabled = quickActionsEnabled;
        settingsFile.quickActionsEdge = quickActionsEdge;
        settingsFile.umbraMotion = umbraMotion;
        settingsFile.umbraUseWallpaper = umbraUseWallpaper;
        settingsFile.umbraBlurWallpaper = umbraBlurWallpaper;
        settingsFile.umbraShowMedia = umbraShowMedia;
        settingsFile.umbraShowWeather = umbraShowWeather;
        settingsFile.umbraPamService = umbraPamService;
        settingsFile.showLauncherButton = showLauncherButton;
        settingsFile.showSettingsButton = showSettingsButton;
        settingsFile.showWorkspaces = showWorkspaces;
        settingsFile.showFocusedWindow = showFocusedWindow;
        settingsFile.showSystemStats = showSystemStats;
        settingsFile.showAudio = showAudio;
        settingsFile.showMedia = showMedia;
        settingsFile.showMediaProgress = showMediaProgress;
        settingsFile.showMediaTime = showMediaTime;
        settingsFile.showTray = showTray;
        settingsFile.showNetworkLabel = showNetworkLabel;
        settingsFile.showBluetooth = showBluetooth;
        settingsFile.showBrightness = showBrightness;
        settingsFile.showBattery = showBattery;
        settingsFile.showMicrophone = showMicrophone;
        settingsFile.showSeconds = showSeconds;
        settingsFile.showDate = showDate;
        settingsFile.doNotDisturb = doNotDisturb;
        settingsFile.launcherMaxResults = launcherMaxResults;
        settingsFile.showLauncherHints = showLauncherHints;
        settingsFile.showAppDescriptions = showAppDescriptions;
        settingsFile.wallpaperColumns = wallpaperColumns;
        settingsFile.wallpaperPath = wallpaperPath;
        settingsFile.wallpaperKind = wallpaperKind;
        settingsFile.wallpaperOutputs = wallpaperOutputs;
        settingsFile.wallpaperTransition = wallpaperTransition;
        settingsFile.weatherEnabled = weatherEnabled;
        settingsFile.weatherLocation = weatherLocation;
        settingsFile.temperatureUnit = temperatureUnit;
        settingsFile.terminal = terminal;
        settingsFile.browser = browser;
        settingsFile.fileManager = fileManager;
        settingsFile.dateFormat = dateFormat;
        settingsFile.writeAdapter();
    }

    onCompactChanged: queueSave()
    onTextIconsChanged: queueSave()
    onMotionChanged: queueSave()
    onAnimateStarsChanged: queueSave()
    onAtmosphereStyleChanged: queueSave()
    onAdaptivePaletteChanged: queueSave()
    onMotionStyleChanged: queueSave()
    onAccentNameChanged: queueSave()
    onTypographyProfileChanged: queueSave()
    onFontTextChanged: queueSave()
    onFontDisplayChanged: queueSave()
    onFontMonoChanged: queueSave()
    onFontIconChanged: queueSave()
    onBarModeChanged: queueSave()
    onBarMarginChanged: queueSave()
    onBarOpacityChanged: queueSave()
    onQuickActionsEnabledChanged: queueSave()
    onQuickActionsEdgeChanged: queueSave()
    onUmbraMotionChanged: queueSave()
    onUmbraUseWallpaperChanged: queueSave()
    onUmbraBlurWallpaperChanged: queueSave()
    onUmbraShowMediaChanged: queueSave()
    onUmbraShowWeatherChanged: queueSave()
    onUmbraPamServiceChanged: queueSave()
    onShowLauncherButtonChanged: queueSave()
    onShowSettingsButtonChanged: queueSave()
    onShowWorkspacesChanged: queueSave()
    onShowFocusedWindowChanged: queueSave()
    onShowSystemStatsChanged: queueSave()
    onShowAudioChanged: queueSave()
    onShowMediaChanged: queueSave()
    onShowMediaProgressChanged: queueSave()
    onShowMediaTimeChanged: queueSave()
    onShowTrayChanged: queueSave()
    onShowNetworkLabelChanged: queueSave()
    onShowBluetoothChanged: queueSave()
    onShowBrightnessChanged: queueSave()
    onShowBatteryChanged: queueSave()
    onShowMicrophoneChanged: queueSave()
    onShowSecondsChanged: queueSave()
    onShowDateChanged: queueSave()
    onDoNotDisturbChanged: queueSave()
    onLauncherMaxResultsChanged: queueSave()
    onShowLauncherHintsChanged: queueSave()
    onShowAppDescriptionsChanged: queueSave()
    onWallpaperColumnsChanged: queueSave()
    onWallpaperPathChanged: queueSave()
    onWallpaperKindChanged: queueSave()
    onWallpaperOutputsChanged: queueSave()
    onWallpaperTransitionChanged: queueSave()
    onWeatherEnabledChanged: queueSave()
    onWeatherLocationChanged: queueSave()
    onTemperatureUnitChanged: queueSave()
    onTerminalChanged: queueSave()
    onBrowserChanged: queueSave()
    onFileManagerChanged: queueSave()
    onDateFormatChanged: queueSave()

    property Timer saveTimer: Timer {
        interval: 220
        onTriggered: root.saveNow()
    }

    property Process ensureDirectory: Process {
        command: ["mkdir", "-p", root.configRoot]
        running: true
        onRunningChanged: {
            if (!running)
                settingsFile.reload();
        }
    }

    property FileView settingsFile: FileView {
        id: settingsFile
        property alias compact: settingsAdapter.compact
        property alias textIcons: settingsAdapter.textIcons
        property alias motion: settingsAdapter.motion
        property alias animateStars: settingsAdapter.animateStars
        property alias atmosphereStyle: settingsAdapter.atmosphereStyle
        property alias adaptivePalette: settingsAdapter.adaptivePalette
        property alias motionStyle: settingsAdapter.motionStyle
        property alias accentName: settingsAdapter.accentName
        property alias typographyProfile: settingsAdapter.typographyProfile
        property alias fontText: settingsAdapter.fontText
        property alias fontDisplay: settingsAdapter.fontDisplay
        property alias fontMono: settingsAdapter.fontMono
        property alias fontIcon: settingsAdapter.fontIcon
        property alias barMode: settingsAdapter.barMode
        property alias barMargin: settingsAdapter.barMargin
        property alias barOpacity: settingsAdapter.barOpacity
        property alias quickActionsEnabled: settingsAdapter.quickActionsEnabled
        property alias quickActionsEdge: settingsAdapter.quickActionsEdge
        property alias umbraMotion: settingsAdapter.umbraMotion
        property alias umbraUseWallpaper: settingsAdapter.umbraUseWallpaper
        property alias umbraBlurWallpaper: settingsAdapter.umbraBlurWallpaper
        property alias umbraShowMedia: settingsAdapter.umbraShowMedia
        property alias umbraShowWeather: settingsAdapter.umbraShowWeather
        property alias umbraPamService: settingsAdapter.umbraPamService
        property alias showLauncherButton: settingsAdapter.showLauncherButton
        property alias showSettingsButton: settingsAdapter.showSettingsButton
        property alias showWorkspaces: settingsAdapter.showWorkspaces
        property alias showFocusedWindow: settingsAdapter.showFocusedWindow
        property alias showSystemStats: settingsAdapter.showSystemStats
        property alias showAudio: settingsAdapter.showAudio
        property alias showMedia: settingsAdapter.showMedia
        property alias showMediaProgress: settingsAdapter.showMediaProgress
        property alias showMediaTime: settingsAdapter.showMediaTime
        property alias showTray: settingsAdapter.showTray
        property alias showNetworkLabel: settingsAdapter.showNetworkLabel
        property alias showBluetooth: settingsAdapter.showBluetooth
        property alias showBrightness: settingsAdapter.showBrightness
        property alias showBattery: settingsAdapter.showBattery
        property alias showMicrophone: settingsAdapter.showMicrophone
        property alias showSeconds: settingsAdapter.showSeconds
        property alias showDate: settingsAdapter.showDate
        property alias doNotDisturb: settingsAdapter.doNotDisturb
        property alias launcherMaxResults: settingsAdapter.launcherMaxResults
        property alias showLauncherHints: settingsAdapter.showLauncherHints
        property alias showAppDescriptions: settingsAdapter.showAppDescriptions
        property alias wallpaperColumns: settingsAdapter.wallpaperColumns
        property alias wallpaperPath: settingsAdapter.wallpaperPath
        property alias wallpaperKind: settingsAdapter.wallpaperKind
        property alias wallpaperOutputs: settingsAdapter.wallpaperOutputs
        property alias wallpaperTransition: settingsAdapter.wallpaperTransition
        property alias weatherEnabled: settingsAdapter.weatherEnabled
        property alias weatherLocation: settingsAdapter.weatherLocation
        property alias temperatureUnit: settingsAdapter.temperatureUnit
        property alias terminal: settingsAdapter.terminal
        property alias browser: settingsAdapter.browser
        property alias fileManager: settingsAdapter.fileManager
        property alias dateFormat: settingsAdapter.dateFormat

        path: root.configPath
        watchChanges: true
        printErrors: root.debug
        onLoaded: root.applyFromDisk()
        onFileChanged: reload()
        onLoadFailed: function(error) {
            if (error === FileViewError.FileNotFound && !root.ensureDirectory.running) {
                root.persistenceReady = true;
                root.saveNow();
            }
        }

        // qmllint disable unresolved-type
        adapter: JsonAdapter {
            id: settingsAdapter
            property bool compact: false
            property bool textIcons: false
            property bool motion: true
            property bool animateStars: true
            property string atmosphereStyle: "nominal"
            property bool adaptivePalette: false
            property string motionStyle: "rise"
            property string accentName: "violet"
            property string typographyProfile: "serpantinum"
            property string fontText: "JetBrains Mono"
            property string fontDisplay: "JetBrains Mono"
            property string fontMono: "JetBrains Mono"
            property string fontIcon: "Iosevka Nerd Font"
            property string barMode: "capsules"
            property int barMargin: 12
            property real barOpacity: 0.94
            property bool quickActionsEnabled: true
            property string quickActionsEdge: "right"
            property bool umbraMotion: true
            property bool umbraUseWallpaper: true
            property bool umbraBlurWallpaper: true
            property bool umbraShowMedia: true
            property bool umbraShowWeather: true
            property string umbraPamService: "login"
            property bool showLauncherButton: true
            property bool showSettingsButton: true
            property bool showWorkspaces: true
            property bool showFocusedWindow: true
            property bool showSystemStats: true
            property bool showAudio: true
            property bool showMedia: true
            property bool showMediaProgress: true
            property bool showMediaTime: true
            property bool showTray: true
            property bool showNetworkLabel: true
            property bool showBluetooth: true
            property bool showBrightness: true
            property bool showBattery: true
            property bool showMicrophone: true
            property bool showSeconds: true
            property bool showDate: true
            property bool doNotDisturb: false
            property int launcherMaxResults: 80
            property bool showLauncherHints: true
            property bool showAppDescriptions: true
            property int wallpaperColumns: 3
            property string wallpaperPath: ""
            property string wallpaperKind: "image"
            property string wallpaperOutputs: "all"
            property string wallpaperTransition: "any"
            property bool weatherEnabled: true
            property string weatherLocation: "Oslo, Norway"
            property string temperatureUnit: "celsius"
            property string terminal: "terminology"
            property string browser: "firefox"
            property string fileManager: "nautilus"
            property string dateFormat: "yyyy · MM · dd"
        }
    }
}
