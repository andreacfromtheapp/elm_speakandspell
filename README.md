# Speak & Spell in Elm

My very first attempt at an [Elm](https://elm-lang.org/) application. Created to test my understanding of Elm and of my learning with ["Elm in Action"](https://www.manning.com/books/elm-in-action).

Why Speak & Spell? Because there was room for a good mix of UI/UX and for a great starting point to learn and practice. I fancied creating completely from scratch and not basing my learning on pre-existing concepts.

Being a *toy project* (no pun intended), this is a limited reproduction of the original game:

1) match the word on the screen
2) use the commands.

No *Mystery Word* or other play modes from the original Speak & Spell.

The point of this exercise was to: study, internalize, apply, learn some more, improve skills and code, rinse and repeat. Not to be an 1:1 clone.

When I first started this project, I hadn't finished the book yet. In fact, I started it right after finishing Chapter 5: all the basics up to testing. I needed to internalize the concepts I had learned so far, and to make sure I was getting them. After some time, and after improving my skills on [Exercism](https://exercism.org/profiles/gacallea) and doing some exploring, I have:

- migrated the code to [my template](https://github.com/gacallea/elm_vite_tailwind_template).
- migrated the code to [Tailwind CSS](https://tailwindcss.com/)
- made it reponsive.
- resumed the book from where I left off: Chapter 6: Testing
- wrote all tests.

With all tests complete, the project fully served its purpose and it is now complete.

Initially, I used [Elm UI](https://github.com/gacallea/elm_speakandspell/tree/elm_ui_version) for the UI/UX. However, I hit a stopper when doing responsive design. Whilst Elm UI does permit good responsive design, the way I had laid out the UI would have meant to refactor everything. Since Elm UI was an experiment for me, and that I should have refactored everything UI anyway, I have switched to [Tailwind CSS](https://tailwindcss.com/) and made this reponsive to the best of my abilities.

## Made With

Tooling privided by [Vite, Elm, and Tailwind CSS, Template](https://github.com/gacallea/elm_vite_tailwind_template). Check it out :)

## Credits & Copyright

[Speak & Spell](https://en.wikipedia.org/wiki/Speak_%26_Spell_(toy))™ is © of Texas Instruments Inc.

The favicon used on the Vercel app is © [Gregor Cresnar](https://thenounproject.com/icon/speak-1616157/). Licensed under the [Creative Commons CC-BY 3.0](https://creativecommons.org/licenses/by/3.0/).
