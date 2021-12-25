# Speak & Spell in Elm

This is my very first attempt at an [Elm](https://elm-lang.org/) app. I'm doing this to test my understanding of Elm and of my learning with ["Elm in Action"](https://www.manning.com/books/elm-in-action). I haven't finish the book yet and I could not resist trying to apply what I've learned so far.

I picked Speak & Spell because it's a good mix of UI/UX and it makes for a great starting point to learn and practice. It will never be more than a simple "*first project*" exercise. Being a *toy project* (no pun intended), it won't have too many features. I'll make it good enough to learn, and move on to resume my Elm learning path.

The code certainly stinks, and I’m aware that it needs more love and that there is room for improvement. That's the point of this exercise: study, internalize, apply, learn some more, improve skills and code, rinse and repeat.

## Try it

Don't want to [install Elm](https://guide.elm-lang.org/install/)? Paste [Main.elm](./src/Main.elm) and [index.html](./index.html) on [Ellie App](https://ellie-app.com/new) to run it in your browser.

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
    - [x] allow alphabet characters
    - [x] allow commands keyboard shortcuts
      - [x] ~~**FIX**: Sumbit It keyboard shortcut doesn't use the right word~~
    - [x] send keycode to screen (see "user feedback" section)
    - [x] send keycode to speak (see "user feedback" section)
- [x] text to speech 🤖🤖🤖
  - [x] [SpeechSynthesis Web API](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis) with a JavaScript Port
  - [x] let user disable voice
    - [x] completely
    - [x] ~~for some features~~ **(no. API only pauses/resumes global state)**
      - [x] ~~just keys~~
      - [x] ~~just feedback~~
  - [x] no need for Sub (for now?)
- [x] refactor ```update``` and use helper functions
  - [x] reuse helper functions to streamline code
  - [x] declutter view's onClick events and use update for Msg
  - [x] not all Msg need to be parametrized
---
- [x] now using a type Output with a case
  - [x] much clearer and less convoluted code
  - [x] it can either be Info (init text), Word, or Result upon sumbit
- [x] ~~use a Maybe String for model.click to~~
  - [x] ~~show default message or GuessWord~~
  - [x] ~~implement a conditional to only show GuessWord if valid~~
  - [x] ~~awlays show clicked Nothing if GuessWord is empty~~
---
- [x] output screen
  - [x] has user started entering a word?
    - [x] no: display default messasge telling the user what to do
    - [x] yes: display typed text
  - [x] erase letter: if guess word is emtpy display default message
  - [x] retry/reset: display default message
  - [x] submit: result text to take over as the only text on screen

### UI/UX

- [ ] vanilla CSS? SASS? PostCSS? elm-css? elm-ui? or even SVG?!?
- [ ] [ARIA](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA) accessibility
- [ ] responsive design
  - [ ] mobile first
  - [ ] no onscreen keyboard on mobile
- [ ] loosely look like Speak & Spell (make it look & feel like a toy)
  - [ ] keys (vowels, consonants, commands) to look different
  - [ ] use random emojis in lieu of the Elm logo?
- [ ] user feedback
  - [x] feedback for keypresses
    - [x] written feedback
    - [x] auditory feedback with SpeechSynthesis
    - [ ] visual feedback (CSS animations?)
  - [x] feedback upon checking the spelling
    - [x] written feedback
    - [x] auditory feedback
    - [ ] visual feedback (CSS animations?)
- [ ] screen
  - [ ] retro-looking/low-fi/8bit
  - [ ] expandable "side loading screen" for the description?
  - [ ] expandable "bottom loading screen" for the help section
    - [x] help toggle in Elm (temporary. exercise more than anything)
  - [ ] fixed "field" for the user output
  - [ ] separate help and commands section

### Improvements

- [ ] should I use a Maybe KeyboardEvent?
- [ ] refactor ```Msg``` and split into ```KeyPressed``` + ```KeyClicked``` types?
  - [ ] would this be too convoluted? Elm likes clarity over complexity

### Maybe

Provided that a *polyglot API* (or separate different languages APIs) exist, these are a number of items I'd like add to the app:

- [ ] let user choose:
  - [ ] a different dictionary language
  - [ ] the voice language, params, and gender
- [ ] internationalization depending on dict language
  - [ ] help
  - [ ] commands
