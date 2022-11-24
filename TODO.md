# TODO

## Logic

### stateful logic

- [x] make [Impossible States Impossible](https://sporto.github.io/elm-patterns/basic/impossible-states.html) 🎉 🎉 🎉
  - [x] managed certainty of ```type Status``` and ```type Output```
    - [x] Status: can only be Loading, Loaded ```something```, and Errored
    - [x] Output screen: can only show one line at the time, depending on user input
- [x] avoid [boolean identity crisis](https://www.youtube.com/watch?v=6TDKHGtAxeg) 🥳 🥳 🥳
  - [x] see ```type Sound```

### keyboard

- [x] display keyboard onscreen
- [x] onclick events to output
- [x] onclick events to sound
- [x] use an [package](https://package.elm-lang.org/packages/Gizra/elm-keyboard-event/latest/) to get user typing
- [x] get keycode from typing into onscreen keyboard
- [x] filter out KeyPressed to
  - [x] if alt/meta/shift/ctrl/repeat is pressed do nothing
  - [x] allow alphabet characters
  - [x] allow commands keyboard shortcuts
    - [x] ~~**FIX**: Sumbit It keyboard shortcut doesn't use the right word~~
  - [x] send keycode to screen (see "user feedback" section)
  - [x] send keycode to speak (see "user feedback" section)

### text to speech 🤖🤖🤖

- [x] [SpeechSynthesis Web API](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis) with a JavaScript Port
- [x] let user disable voice
  - [x] completely
  - [x] ~~for some features~~ **(no. API only pauses/resumes global state)**
    - [x] ~~just keys~~
    - [x] ~~just feedback~~
- [x] no need for Sub (for now?)

### refactor

- [x] refactor ```update``` and use helper functions
  - [x] reuse helper functions to streamline code
  - [x] declutter view's onClick events and use update for Msg
  - [x] not all Msg need to be parametrized

### output screen

- [x] ~~use a Maybe String for model.click to~~
  - [x] ~~show default message or GuessWord~~
  - [x] ~~implement a conditional to only show GuessWord if valid~~
  - [x] ~~awlays show clicked Nothing if GuessWord is empty~~
- [x] switch to using ```type Output``` with a ```case ... of```
  - [x] much clearer and less convoluted code
  - [x] it can either be Init, Holder, Word, or Result upon sumbit
  - [x] avoid double use of Maybe Strings that depended on one another
- [x] has user started entering a word?
  - [x] no: display default messasge telling the user what to do
  - [x] yes: display typed text
- [x] erase letter: if guess word is emtpy display default message
- [x] retry/reset: display default message
- [x] submit: result text to take over as the only text on screen

## UI/UX

- [x] look like Speak & Spell (make it look & feel like a toy)
  - [x] keys (alphabet, commands) to look different
- [x] user feedback
  - [x] feedback for keypresses
    - [x] written feedback
    - [x] auditory feedback with SpeechSynthesis
    - [x] visual feedback (change color)
    - [x] is key stuck?
  - [x] feedback upon checking the spelling
    - [x] written feedback
    - [x] auditory feedback
- [x] screen
  - [x] retro-looking/low-fi/8bit
  - [x] fixed "field" for the user output
  - [x] Elm Instruments
  - [x] add logo besides "brand"
- [x] create a custom loading page
  - [x] use elm logo :)
  - [x] spell LOADING with Speak & Spell styled keys
  - [x] animate the LOADING words on screen
- [x] create custom error page
  - [x] implement function to handle http.error
  - [x] and return custom (parsed) error messages
- [x] [ARIA](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA) accessibility
- [x] SEO optimization
- [x] make elm-ui design responsive
  - [x] elm ui seems abandonware
  - [x] making it responsive is a bit PITA
  - [x] leaving as is and will do proper CSS (elm-css?) reponsive design later

## Improvements

- [x] [Elm optmization](https://guide.elm-lang.org/optimization/):
  - [x] remove debug.string + refactor those fn
  - [x] use lazy
  - [x] assets size
  - [x] use local fonts
- [x] use parceljs

## Maybe

- [ ] make it so that KeyPressed triggers visual feedback on keyboard keys
  - [ ] should I use a Maybe KeyboardEvent?
  - [ ] refactor ```Msg``` and split into ```KeyPressed``` + ```KeyClicked``` types?
    - [ ] would this be too convoluted? Elm likes clarity over complexity

Provided that a *polyglot API* (or separate different languages APIs) exist, these are a number of items I'd like add to the app:

- [ ] let user choose:
  - [x] a different dictionary language
  - [ ] the voice language, params, and gender
- [x] internationalization depending on chosen dict language
  - [x] UI
  - [x] commands

## Deploy

Once complete, deploy a static website:

- [x] ~~deploy to [GitHub Pages](https://docs.github.com/en/pages)~~
  - [x] gh pages sucks!!!
  - [x] c'mon microsoft... learn from gitlab.
- [x] vercel app :)
