import { Elm } from "./Main.elm";

let app = Elm.Main.init({
    // get window size with flags
    flags: {
        win_width: window.innerWidth,
        win_height: window.innerHeight,
    },

    // Start the Elm application.
    node: document.querySelector("main"),
});

// Instantiate Speech Synth API
let synth = window.speechSynthesis;
let utter = new SpeechSynthesisUtterance();

// Pause/Resume Speech Synth API (SetSound On | Off)
app.ports.sound.subscribe(function (message) {
    synth.cancel();
    if (message == true) {
        synth.resume();
    } else {
        synth.pause();
    }
});

// We receive the whole word here and speak it
app.ports.speak.subscribe(function (message) {
    utter.text = message;
    synth.speak(utter);
});

// We receive the split word here and spell it
app.ports.spell.subscribe(function (message) {
    utter.text = message;
    synth.speak(utter);
});
