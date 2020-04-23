![Pull-subtrees](https://github.com/timueh/sars-cov2-modelling-initiative/workflows/Pull-subtrees/badge.svg)

# Code repository for the SARS-CoV2 modelling initiative

The SARS-CoV2 Modelling Initiative is a loose conglomerate of scientists concerned about the outbreak of Covid 19.
The main focus of the initiative is the situation in Germany.
The scientific background of the initiative varies from epidemiologists, physicians, economists to mathematicians and physicists.

__This repository serves as a hub to collect code related to the initiative.__
[__Click here to see the list of all packages.__](list-of-packages.md)



If you would like to become a member of the repository, please contact tillmann.muehlpfordt@kit.edu.

If you are new to Git, [see below](#why-git/github).

## Goals and objectives

- provide single point of reference
- make your work transparent and accountable
- allow for reproducibility
- reduce communication overhead

## Recommended workflow

Suppose you would like to add your code to the repository.
How do you do it?
There are basically two ways how you can contribute.

## Case 1: You already have your code in a GitHub repository

- Open an issue informing that you would like your code to be added.
- Your code will then be pulled via `git subtree`([see this post for a comparison of `git subtree` and `git submodule`](https://codewinsarguments.co/2016/05/01/git-submodules-vs-git-subtrees/)).
- Whenever you make changes to your original repo, you open another issue to pull in your existing code; no pull requests are needed.

## Case 2: You don't have the code in a repository

- Fork from this repository, see [this excellent guide](https://guides.github.com/activities/forking/).
- Add your code to the repository:
    - Check whether there exists a directory for your programming language (Python, R, Julia, Matlab, ...).
        - If not, create a directory for your programming language
        - Then, create a directory for your code in the programming lanauge directory.
- Make a pull request.

## Why Git/GitHub?

If you are unfamiliar with Git and/or GitHub, do not worry.
As usual, new tools seem overly complex in the beginning, and one wonders "why bother with yet another new tool?"
Generally speaking, [Git](https://en.wikipedia.org/wiki/Git) is a version control system for source code;
GitHub is a website that amplifies the collaborative aspect of using Git: it allows to comment on code changes, and serves as a single hub for every line of code.
Another great advantage of GitHub is that it is a near-perfect implementation of *if you see something, say something*, meaning the following: if you find a typo or a bug, then *you* can fix it.
GitHub is a great catalyst for self-correction.

__Why bother with Git?__

There are several advantages.
Here's a list of personal favorites:
- facilitate code review
- track your progress
- make code visible
- introduce accountability
- allow for collaboration
- encourage clean(er) code

Regardless of why you use Git, it's one of these things where you wonder why you haven't heard of it before.
Once you get the hang of it, you will not want to do without.

By the way: [Git just turned 15](https://www.heise.de/developer/meldung/15-Jahre-Git-Die-Versionsverwaltung-fuer-Quellcode-hat-Wurzeln-geschlagen-4698023.html). 

## New to Git/GitHub?

If you are a beginner, perhaps the most important idea to rectify is: Git is *not* GitHub.
Git is a software that helps with source code control; GitHub is a website that *uses* Git and adds collaborative aspects.

The amount of tutorials for Git is seemingly endless.
Here are three suggestions:
- There is a gamified learning-by-doing approach: https://learngitbranching.js.org/
- A more concise and to-the-point tutorial is this one: https://rogerdudler.github.io/git-guide/
- If you prefer more traditional tutorials, check out the one by Atlassian: https://www.atlassian.com/git/tutorials/what-is-version-control

Plesae feel free to add to the list.


