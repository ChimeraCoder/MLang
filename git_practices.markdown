Below is a straightforward workflow that I wrote for people without much git experience. At the end, there is a list of common git commands that may be useful to reference. 

(Aditya Mukerjee [chimeracoder], 2011)

Git Intro & Style
==============


This guide is designed to be useful for people with a range of experience with git and other version control. Because of this, we'll start with a sneak peek of the end - a straightforward workflow for using git that you should follow when starting out with git. Read as much of the remainder of this guide as you need to for those seven steps to make sense.

You may not understand everything at first, but having a high-level overview of how you work with git will help you as you learn how git works. As you keep reading, these seven steps will begin to make more and more sense.


The Simple, Straightforward, Inelegant-but-Foolproof Git Workflow
--------------------------


This workflow may be a bit redundant for a git pro, but it's the simplest way to avoid headaches for git beginners.

Basically, you only work in feature branches that never leave your machine. You only push/pull from 'mainstream' branches in which you **never edit files directly**. You link these two worlds by merging feature branches into 'mainstream' branches (which correspond to branches hosted on Github).

(Assume that we are starting with a freshly cloned repository. We'll call the current branch testing1, since it doesn't need to be master).

0. **Pull the branch** (git pull testing1). (Do this if you are not starting with a freshly cloned repository. Make sure you specify the branch name, or you will pull from the wrong branch on GitHub).

1. **Make a new feature branch** (git branch NEWBRANCH). This feature branch will only exist on your machine, and you are free to delete it (git branch -d BRANCHNAME) once it has been merged and pushed . Please do not clutter up the foreign repo by pushing extraneous feature branches.

2. **Switch to the feature branch** (git checkout NEWBRANCH). (You have just switched from testing1 to NEWBRANCH).

3. **Make changes, commit** (git add FILE; git commit FILE). Repeat until the feature is done, and you are ready to merge back into the original branch.

4. **Switch to the original branch** (git checkout testing1).

5. **Pull the changes from the origin** (git pull origin testing1). (Make sure you use the right name for testing1, or you will pull changes from the wrong branch!). If you have been following this process properly, you cannot have merge conflicts at this stage, because you have never edited the testing1 branch on your machine since you last pulled it).

5. **Rebase the feature branch into the current branch**. (git rebase NEWBRANCH) Only the last commit message will be kept!

6. **Push the newly rebased current branch to GitHub**. (git push origin testing1). (**Make sure you include the foreign branch name, or you will end up pushing to master by default!**)

7. You're done!


Why use version control?
-----------------

That all looks kind of complicated. Why do we do it? How many times have you changed some code, only to realize the next day that you broke an older part and can't remember what you did before to fix it? Or commented out vast chunks of code to test something?

You could create a new folder in each directory, with the day's name, and just save a 'snapshot' of your day's work at the end of each day. It's not a bad idea, and you should be backing up your files anyway, but what do you do if you want to merge *some* changes from an old version into the current version? And let's say you decide to loop back or merge those changes in - the timeline is linear, but the versions aren't. You can try and fix this by grouping these timestamped snapshot folders into larger folders, but that gets kind of gets messy - almost the sort of stuff you'd want to automate in a script. 

Well, in a way, that's exactly what git *does*. Git is simply a way of automating that entire process and making it cleaner. (And adding some extra features along the way).

In git, you **commit** your changes instead of creating a new folder to take a new snapshot. You also add a *commit message* that describes what changes you made, which is a lot more helpful than just having the date. Instead of having putting those timestamped snapshot folders inside larger folders, you just create a new *branch* and then *merge* that branch back when you're done. 


Branching
-------------------------

Branching is at the core of git. Git's ability to create, merge, delete, and share (push/pull) branches very easily is the reason it's so popular as a source control method.

Let's say you're on a team with two other people, working on a project with a few different files. Git lets you work on your files while your team members work on theirs *at the same time*. In fact, unlike some version control methods, git even lets you both work *on the same file* at the same time (though you should be cautious with this).

What's more, if the others finish their work, git lets you **pull** their changes and **merge** them with your local files, so that you can use the latest version. And you can do this *without* distributing your untested, work-in-progress files - you can wait until you're done with that before **push**ing those changes so that others can see them.

While working on one feature, if you get a crazy idea for a new one, you can *branch* off your work midway and start working on that instead. If it works out, *merge* your changes back to the first feature branch. If not, you can just go back to the point at which you branched off and forget that crazy idea ever happend. No need to figure out what code to delete or how to revert it - git will do that for you.

And (here's where it gets wild, particularly if you're used to SVN) you don't even need a central server to contain the 'master' or 'official' copy. Github works well as a pseudo-central server, but really, you don't actually need that at all. Git is *distributed*, which makes it really good for handling multiple people working individually or in small teams as part of a larger project.

The reason git does this so well is because everyone is (ideally) working on different *branches*. Sometimes (confusingly), those branches may have the same name - but don't be fooled. The 'master' branch on my computer is different from the 'master' branch on your computer. (A smart git workflow will take advantage of this naming 'coincidence').

The key to a good git workflow is to keep your branches separate mentally. One set of branches will be the branches that other people may want to see. Usually this will have the 'master' branch, along with a few other branches for dedicated versions of your project (one per sub-team) - the specifics are project-specific and a matter of style. However you decide to do this, *make sure that everyone refers to the branches by the same name*. If there is a 'master' branch on GitHub as well as a 'shadow' branch, make sure that the corresponding branches on your hard drive use the same names as well. This will save you lots of money on ibuprofen.

The second set of branches are 'secret' - they're the ones that nobody ever sees. You work on those, commit your changes frequently, and then, when you're ready to give the updated files to everyone else, merge the 'secret' branches back into the 'for-public' branches. If you use the workflow in this document, *only the net effect will be saved* - all of the 1000 commits that you did on the 'secret' branch will just be lumped together as one big change. This is part of the process known as *rebasing*.


You should never work on a 'for-public' branch directly, except to merge your 'secret' branches in. This will get you in the habit of using git frequently and commiting frequently, which is good. It also means that you'll be resolving any merge conflicts locally, which is better than resolving them against a shared repository. If you follow this guide, merge conflicts should be infrequent, but when they happen, it's best to be able to fix them on your own computer, so you only edit the shared repositor(ies) once the problems are resolved.

Money doesn't grow on trees, but branches do. They're free, so use them freely. Every time you start working on something new, make a new branch. If things go wrong, it's easier to revert changes when you're working with separate branches. 


So, in short: *Always create a new branch for writing new code. Never edit the local branches that correspond to remote ('shared') branches directly. Instead, create a new feature branch locally, commit frequently to that branch, and then merge the feature branch back into the local copy of the remote branch when you're done. Once everything is order, push the local copy of the remote branch to the remote server, so that others can see it.*



Additional tips
---------------------------

* In git, everyone can do work simultaneously and independently, and the changes are simply merged. In git-speak, we say that people are working on a file 'at the same time' if one person starts editing a file while another person has changes to that file locally (that they haven't yet pushed).
 
* Git does a good job of merging without conflict, but it's not perfect. You can reduce the odds of merge conflicts by having only one person work on any given file at a time.
 
* If that isn't possible, at least make sure that they are working on different parts of the file. Don't move code around within a file in this case; wait until you are the only one working with a file before doing major refactoring.
 
* If merge/rebase conflicts get out of control, **relax**. This is why you've been using branches in the first place.
  * First, make sure that your ('secret') feature branch FEATUREBRANCH is exactly how you want it to be (git-log helps).
  * Then, switch to the local copy of the 'for-public' branch that you're trying to merge it into.
  * **Reset** this branch to an earlier point, when you knew there was no conflict. 
  * Then, **pull* the remote changes to this branch (to bring it back up to speed with others' changes). This whole process just flushes anything that may have gone wrong while you were merging, and because you didn't do anything to FEATUREBRANCH, your hard work is safe.
  * Now, merge FEATUREBRANCH into the local copy of the 'for-public' branch. (If git complains about files from an earlier rebase, just tell it abort the rebase and retry. If git still complains, just do this entire fix again from the beginning, and merge without rebasing (git merge FEATUREBRANCH, with no --rebase).



Appendix
========


Basic Git commands
-------------------

After setting up your repository , there are only a few git commands you need to know in order on a daily basis.


   $ git add [file]

Adds [file] to the staging area, but does not commit it. If the file has not yet been committed, or i there are changes in the file since it was last committed, the file is added. Otherwise, no action.


   $ git diff 

See if there have been any unstaged changes since the last commit (ie, the things you should probably run git add on)

   $ git diff --cached

See what changes are staged to be commited (ie, what will be commited if you run git commit -a)

   $ git commit [file]

Commits the changes in [file] to the current branch, and opens up a text editor so that you can write a brief message explaining the changes. 

Two useful variations:

*git commit -a* will commit the changes in all files that haveever been added to the repository (via git add), not just the ones currently in the staging area.

*git commit -m* will allow you to write the commit message at the command line:

   git commit -am "I just committed the changes in all my files"

As with most POSIX commands, you can combine the -a and -m flags, but be careful when viewing your shell history, or you may end up committing the same message twice!


   $ git branch

Show the branches in the repo, and indicate which one is current

   $ git branch [NEW-BRANCH-NAME]

Create a new branch, but do not switch to it (yet).

   $ git checkout [BRANCH-NAME]

Switch to the specified branch


   $ git merge [BRANCH/HEAD]

Merge the changes *from* the specified branch (or commit-head) *into* the *currrent* branch. Hopefully will not result in merge conflicts. All the intermediate commit messages will be kept.

   $ git rebase BRANCH

This is almost like git-merge, except that only the last commit message will be visible in the log. (This isn't technically correct, but pretend it is). The advantage of this is that you can commit early and often on a feature branch without cluttering up the history for others, as people will only see the last commit message.

   $ git push origin [BRANCH]

Assuming that you have configured github as 'origin', pushes the current branch 

Note: Git distinguishes between branch names on different copies of the repository. Technically, Git sees the 'master' branch on your hard drive and the 'master' branch on Github as two different branches.

To avoid confusion, if you are not used to Git, it is a good idea to make sure that your local and branch names are the same (which git does by default). So, before you push to master, make sure that you are currently on branch master locally (use git branch)


   $ git pull 

Fetches the changes from [BRANCH] located at origin and merges them into the current branch. (Literally - this command just runs git fetch; git merge). Make sure that you have committed all staged/unstaged changes before pulling! 




###### Permission is granted to copy, distribute and/or modify this document under the terms of the GNU Free Documentation License, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts and no Back-Cover Texts.
