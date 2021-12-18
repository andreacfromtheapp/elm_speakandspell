# Speak & Spell in Elm

This is my very first attempt at an [Elm](https://elm-lang.org/) app. I'm doing this to test my understanding of Elm and of my learning with ["Elm in Action"](https://www.manning.com/books/elm-in-action). I haven't finish the book yet and I could not resist trying to apply what I've learned so far.

I picked Speak & Spell because it's a good mix of UI/UX and as a starting point to learn and practice. It will never be more than a simple exercise. A good "*first project*" kinda thing.

The code certainly stinks, and I’m well aware that it needs more love and that there is room for improvement. That's the point of this exercise: study, internalize, apply, learn some more, improve skills and code, rinse and repeat.

## Try it

Don't want to install Elm? Paste [Main.elm](./src/Main.elm) and [index.html](./index.html) on [Ellie App](https://ellie-app.com/new) to run it in your browser.

## TODO

- [x] stateful logic 🥳
  - [x] make [Impossible States Impossible](https://sporto.github.io/elm-patterns/basic/impossible-states.html) 🎉 🎉 🎉
- [x] [boolean identity crisis](https://www.youtube.com/watch?v=6TDKHGtAxeg) avoided (type Sound) 🥳 🥳 🥳
- [x] keyboard
  - [x] display keyboard onscreen
  - [x] onclick events to output
  - [x] onclick events to sound
  - [x] use an [package](https://package.elm-lang.org/packages/Gizra/elm-keyboard-event/latest/) to get user typing
  - [x] get keycode from typing into onscreen keyboard
  - [x] filter out KeyPressed to
    - [x] if alt/meta/shift/ctrl/repeat is pressed do nothing
    - [x] only allow alphabet characters
    - [x] only allow single character
    - [x] send keycode to screen (see "user feedback" section)
    - [x] send keycode to speak (see "user feedback" section)
- [x] text to speech 🤖🤖🤖
  - [x] [SpeechSynthesis Web API](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis) with a JavaScript Port
  - [x] let user disable voice
    - [x] completely
    - [x] ~~for some features~~ **(this ain't possible 'cause API only pauses/resumes global voice state)**
      - [x] ~~just keys~~
      - [x] ~~just feedback~~
  - [x] no need for Sub (for now?)
- [ ] UI/UX
  - [ ] loosely look like Speak & Spell
    - [ ] still make it look like a toy looking device
    - [ ] CSS? elm-css? elm-ui?
    - [ ] keys (vowels, consonants, commands, to look different)
    - [ ] use random emojis in lieu of the logo
  - [ ] user feedback
    - [x] feedback for keypresses
      - [x] auditory feedback with SpeechSynthesis
      - [ ] visual feedback with CSS (animations?)
    - [x] feedback upon checking the spelling
      - [x] written feedback
      - [x] auditory feedback
  - [ ] screen
    - [ ] flashy flashy? low-fi/8bit looking?
    - [ ] expandable "side loading screen" for the description?
    - [ ] expandable "bottom loading screen" for the help section
      - [x] help toggle "solution" in Elm (temporary. exercise more than anything)
    - [ ] fixed "field" for the user output
    - [ ] separate help and commands section

### Improvements

- [ ] should I use a Maybe String for GuessWord?
- [ ] should I use a Maybe KeyboardEvent?
- [ ] should I implement commands keyboard shortcuts?
- [ ] refactor ```update``` and use helper functions?

### Maybe

Provided that a *polyglot API* (or separate different languages APIs) exist, these are a number of items I'd like add to the app:

- [ ] let user choose:
  - [ ] a different dictionary language
  - [ ] the voice language, params, and gender
