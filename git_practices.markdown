Git Intro & Style
==============


Below is a straightforward workflow for people without much git experience. At the end, there is a list of common git commands that may be useful to reference. 

The Simple, Straightforward, Inelegant-but-Foolproof Git Workflow
--------------------------


This workflow may be a bit redundant for a git pro, but it's the simplest way to avoid headaches for git beginners.

Basically, you only work in feature branches that never leave your machine. You only push/pull from 'mainstream' branches in which you _never edit files directly_. You link these two worlds by merging feature branches into 'mainstream' branches (which correspond to branches hosted on Github).

(Assume that we are starting with a freshly cloned repository. We'll call the current branch testing1, since it doesn't need to be master).

0. _Pull the branch_ (git pull testing1). (Do this if you are not starting with a freshly cloned repository. Make sure you specify the branch name, or you will pull from the wrong branch on GitHub).

1. _Make a new feature branch_. This feature branch will only exist on your machine, and you are free to delete it once it has been merged and pushed (git branch -d). Please do not clutter up the foreign repo by pushing extraneous feature branches.

2. _Switch to the feature branch_ (git checkout NEWBRANCH). (You have just switched from testing1 to NEWBRANCH).

3. _Make changes, commit_. Repeat until the feature is done, and you are ready to merge back into the original branch.

4. _Switch to the original branch_ (git checkout testing1).

5. _Pull the changes from the origin_ (git pull origin testing1). (Make sure you use the right name for testing1, or you will pull changes from the wrong branch!). If you have been following this process properly, you cannot have merge conflicts at this stage, because you have never edited the testing1 branch on your machine since you last pulled it).

5. _Rebase the feature branch into the current branch_. (git rebase NEWBRANCH) Only the last commit message will be kept!

6. _Push the newly rebased current branch to GitHub_. (git push origin testing1). *Make sure you include the foreign branch name, or you will end up pushing to master by default!*)

7. You're done!


Basic Git commands
-------------------

After setting up your repository , there are only a few git commands you need to know in order on a daily basis.


git add [file]

Adds [file] to the staging area, but does not commit it. If the file has not yet been committed, or i there are changes in the file since it was last committed, the file is added. Otherwise, no action.


git diff 

See if there have been any unstaged changes since the last commit (ie, the things you should probably run git add on)

git diff --cached

See what changes are staged to be commited (ie, what will be commited if you run git commit -a)

git commit [file]

Commits the changes in [file] to the current branch, and opens up a text editor so that you can write a brief message explaining the changes. 

Two useful variations:

*git commit -a* will commit the changes in all files that haveever been added to the repository (via git add), not just the ones currently in the staging area.

*git commit -m* will allow you to write the commit message at the command line:

git commit -am "I just committed the changes in all my files"

As with most POSIX commands, you can combine the -a and -m flags, but be careful when viewing your shell history, or you may end up committing the same message twice!


git branch

Show the branches in the repo, and indicate which one is current

git branch [NEW-BRANCH-NAME]

Create a new branch, but do not switch to it (yet).

git checkout [BRANCH-NAME]

Switch to the specified branch


git merge [BRANCH/HEAD]

Merge the changes *from* the specified branch (or commit-head) *into* the *currrent* branch. Hopefully will not result in merge conflicts. All the intermediate commit messages will be kept.

git rebase BRANCH

This is almost like git-merge, except that only the last commit message will be visible in the log. (This isn't technically correct, but pretend it is). The advantage of this is that you can commit early and often on a feature branch without cluttering up the history for others, as people will only see the last commit message.

git push origin [BRANCH]

Assuming that you have configured github as 'origin', pushes the current branch 

Note: Git distinguishes between branch names on different copies of the repository. Technically, Git sees the 'master' branch on your hard drive and the 'master' branch on Github as two different branches.

To avoid confusion, if you are not used to Git, it is a good idea to make sure that your local and branch names are the same (which git does by default). So, before you push to master, make sure that you are currently on branch master locally (use git branch)


git pull 

Fetches the changes from [BRANCH] located at origin and merges them into the current branch. (Literally - this command just runs git fetch; git merge). Make sure that you have committed all staged/unstaged changes before pulling! 

