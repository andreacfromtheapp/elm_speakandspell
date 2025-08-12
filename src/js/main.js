import '../css/style.css'
import { Elm } from '../elm/SpeakAndSpell.elm'

// translations defaults to English
let res = await fetch('translations/translations.en.json')
const translations = await res.json()

// Start the Elm application.
const app = Elm.SpeakAndSpell.init({
  node: document.querySelector('main'),
  flags: { translations }
})

// Set the UI translation in Elm
app.ports.chooseLanguage.subscribe(async (message) => {
  res = await fetch('translations/translations.' + message + '.json')
  const jsonRes = await res.json()

  if (message === 'en') {
    app.ports.setApiUrl.send('http://localhost:3000/en/word')
  // } else if (message === 'nl') {
  //   app.ports.setApiUrl.send('http://localhost:3000/word/dutch')
  }

  app.ports.setLocale.send(jsonRes)
})

// Instantiate Speech Synth API
const synth = window.speechSynthesis

// https://github.com/gacallea/elm_speakandspell/pull/2
function speak (message) {
  const utter = new window.SpeechSynthesisUtterance()
  utter.text = message
  synth.speak(utter)
}

// Pause/Resume Speech Synth API (SetSound On | Off)
app.ports.sound.subscribe((message) => {
  synth.cancel()
  if (message === true) {
    synth.resume()
  } else {
    synth.pause()
  }
})

// We receive the whole word here and speak it
app.ports.speak.subscribe((message) => {
  speak(message)
})

// We receive the split word here and spell it
app.ports.spell.subscribe((message) => {
  speak(message)
})
