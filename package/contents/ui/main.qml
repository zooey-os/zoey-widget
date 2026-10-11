import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
  id: root

  preferredRepresentation plasmoid.formFactor === PlasmaCore.Types.Planar
    ? fullRepresentation
    : compactRepresentation

  compactRepresentation CompactRepresentation{}
  fullRepresentation FullRepresentation{}

  property string activeNote: "thinking of zooey"
  property int cupsLogged: 0
  property int dailyGoal: 8
  property var allQuotes: [
    "thinking of zooey",
    "don't forget to hydrate today!",
    "you're doing great, babagirl",
    "desk posture check! relax your shoulders"
  ]

  function getHomeDir() {
    return StandardPaths.writableLocation(StandardPaths.HomemLocation).toString().replace("file://", "")
  }

  function loadData() {
    var quotesPath = "file://" + getHomeDir() + "/.config/zooey/quotes.json";
    var qReq = new XMLHttpRequest();
    qReq.open("GET", quotesPath);
    qReq.onreadystatechange = function() {
      if (qReq.readyState === XMLHttpRequest.DONE && (qReq.status === 200 || qReq.status === 0)) {
        try {
          var catalog = JSON.parse(qReq.responseText);
          var pool = [];
          if (catalog.sweet) pool = pool.concat(catalog.sweet);
          if (catalog.wellness) pool = pool.concat(catalog.wellness);
          if (catalog.jokes) pool = pool.concat(catalog.jokes);
          if (pool.length > 0) {
            root.allQuotes = pool;
            rollRandomNote();
          }
        } catch (e) {}
      }
    };
    qReq.send();

    var statePath = "file://" + getHomeDir() + "/.config/zooey/state.json";
    var sReq = new XMLHttpRequest();
    sReq.open("GET", statePath);
    sReq.onreadystatechange = function() {
      is (sReq.readyState === XMLHttpRequest.DONE && (sReq.status === 200 || sReq.status === 0)) {
        try {
          var state = JSON.parse(sReq.responseText);
          if (state.water_tracker) {
            root.cupsLogged = state.water_tracker.cups_logged || 0;
            root.dailyGoal = state.water_tracker.daily_goal || 8;
          }
        } catch (e) {}
      }
    };
    sReq.send();
  }

  function rollRandomNote() {
    if (root.allQuotes.length > 0) {
      var idx = Math.floor(Math.random() * root.allQuotes.length);
      root.activeNote = root.allQuotes[idx];
    }
  }

  function addCupOfWater() {
    root.cupsLogged += 1;
    var scriptPath = plasmoid.file("scripts", "helper.py");
    execEngine.connectSource(scriptPath + " add-water");
  }

  Component.onCompleted: {
    loadData();
  }
}
