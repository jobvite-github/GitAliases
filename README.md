# Git Alias / Function Documentation

To get started, you will need to add the code in the [.profile](./.profile) file to your `.profile` file in your User directory ( `~/` ).

Once your `.profile` is updated. In your `.zshrc`, or `.bashrc` depending on which you see in your User directory or are currently using, add in the following line to the end of that file:

```
source ~/.profile
```

<h3 style="display:inline-block"><b>Functions</b></h3>

<details id="addkick">
    <summary><code style="color: #7694A6">addkick()</code></summary>

<br>

**Add Kickoff**

Using this function will allow you to get the latest Kickoff code into any project.
You can specify where you would like to put it by adding in the path after `addkick`, or you can go to that location in your terminal and run `addkick`
```
> addkick
```

or specify the location
```
> addkick ./myfolder
```
</details>
<details id="camp">
    <summary><code style="color: #7694A6">camp()</code></summary>

<br>

**Commit. Add. Message. Push.**

This function combines the steps of adding, committing and pushing.

<sub><b style="color: #DE897C">Caution: This will add all unstaged files. If you want to add only specific files, do a manual `git add` of the files you want, and then use the [cmp](#cmp) function</b></sub>

    > camp "My commit message"
</details>
<details id="cmp">
    <summary><code style="color: #7694A6">cmp()</code></summary>

<br>

**Commit. Message. Push.**

Use this function to commit and push already staged files. If no files are staged, `git add` the files you want to commit. If you want to commit all files, use the [camp](#camp) function

    > cmp "My commit message"
</details>
<details id="gwtn">
    <summary><code style="color: #7694A6">gwtn()</code></summary>

<br>

**Git Worktree New**

For adding a new worktree. This function will create the worktree based on the latest, if any, existing GitHub code, installs npm, and does an initial push of the branch if it isn't already set up. Once you run this command, you will be ready to work on this worktree. This will work both existing and non-existing branches.

    > gwtn projectname
</details>
<details id="start">
    <summary><code style="color: #7694A6">start()</code></summary>

<br>

**Start Kickoff**

Running this function will run `gulp` in the styles folder of your current branch. If it can't find a "style" or "styles" folder anywhere in the project, this will not run.

You can specify the location to run gulp by adding it after `start`

    > start

or specify

    > start myfolder/styling
</details>
<details id="stats">
    <summary><code style="color: #7694A6">stats()</code></summary>

<br>

**Statistics**

Using this shows you, by default, the last 50 commits made to the repo.

You can specify how many results you want to see by adding `-number` after `stats`

    > stats

or specify

    > stats -10
</details>

<h3 style="display:inline-block"><b>Aliases</b></h3>

<details id="add">
    <summary><code style="color: #7694A6">add</code></summary>

<br>

**Git Add**

Equivalent to [`git add`](https://git-scm.com/docs/git-add)

    > add .
    > add file.html
    > add folder/
</details>
<details id="back">
    <summary><code style="color: #7694A6">back</code></summary>

<br>

**Go Back**

This will take you back one commit in time.

    > back
</details>
<details id="branch">
    <summary><code style="color: #7694A6">branch</code></summary>

<br>

**Git Branch**

Equivalent to [`git branch`](https://git-scm.com/docs/git-branch)

    > branch myBranch
</details>
<details id="branches">
    <summary><code style="color: #7694A6">branches</code></summary>

<br>

**List Branches**

This will return a list of all branches in the current repo.

    > branches
</details>
<details id="cam">
    <summary><code style="color: #7694A6">cam</code></summary>

<br>

**Commit. Add. Message.**

Using this will add and commit, with a message, all the untracked files in your branch. If you don't want to commit all files, use the normal `add`, `commit -m` method.

    > cam "My commit message"
</details>
<details idch">
    <summary><code style="color: #7694A6">ch</code></summary>

<br>

**Git Checkout**

Equivalent to [`git checkout`](https://git-scm.com/docs/git-checkout)

    > ch branch-name
</details>
<details id="chr">
    <summary><code style="color: #7694A6">chr</code></summary>

<br>

**Git Checkout Root**

Equivalent to `git checkout root`

    > chr
</details>
<details id="chsb">
    <summary><code style="color: #7694A6">chsb</code></summary>

<br>

**Git Checkout starter_branch**

Equivalent to `git checkout starter_branch`

    > chsb
</details>
<details idcm">
    <summary><code style="color: #7694A6">cm</code></summary>

<br>

**Git Commit**

Equivalent to [`git commit`](https://git-scm.com/docs/git-commit)

    > cm -m "My commit message"
</details>
<details id="fetch">
    <summary><code style="color: #7694A6">fetch</code></summary>

<br>

**Git Fetch**

Equivalent to [`git fetch`](https://git-scm.com/docs/git-fetch)

    > fetch
</details>
<details id="fuck">
    <summary><code style="color: #7694A6">fuck</code></summary>

<br>

**Fuck**

As the name suggests, this is when you've made a terrible oopsie and need to revert back to the `origin/master` branch.

<sub><b style="color: #DE897C">Caution: This is a HARD reset. It will delete all uncommitted work.</b></sub>

    > fuck
</details>
<details id="grs">
    <summary><code style="color: #7694A6">grs</code></summary>

<br>

**Git Reset**

Equivalent to [`git reset`](https://git-scm.com/docs/git-reset)

    > grs origin/mybranch
</details>
<details id="grv">
    <summary><code style="color: #7694A6">grv</code></summary>

<br>

**Git Remote -v**

Equivalent to [`git remote -v`](https://git-scm.com/docs/git-remote#Documentation/git-remote.txt--v).

Use this alias to view the remotes you have referrenced on your machine.

    > grv
</details>
<details id="gwt">
    <summary><code style="color: #7694A6">gwt</code></summary>

<br>

**Git Worktree**

Equivalent to [`git worktree`](https://git-scm.com/docs/git-worktree)

    > gwt add mybranch
</details>
<details id="gwta">
    <summary><code style="color: #7694A6">gwta</code></summary>

<br>

**Git Worktree Add**

Equivalent to [`git worktree add`](https://git-scm.com/docs/git-worktree#Documentation/git-worktree.txt-addltpathgtltcommit-ishgt)

    > gwta mybranch
</details>
<details id="gwtl">
    <summary><code style="color: #7694A6">gwtl</code></summary>

<br>

**Git Worktree List**

Lists all worktrees

    > gwtl
</details>
<details id="gwtr">
    <summary><code style="color: #7694A6">gwtr</code></summary>

<br>

**Git Worktree Remove**

Equivalent to [`git worktree remove`](https://git-scm.com/docs/git-worktree#Documentation/git-worktree.txt-remove)

    > gwtr /path/to/branchName
</details>
<details id="peek">
    <summary><code style="color: #7694A6">peek</code></summary>

<br>

**Peek**

Using this alias allows you to view, by default, the last 20 commits on your current branch.

Very similarly to [stats](#stats), you can specify how many commits you would like to see.

    > peek

or specify

    > peek -5
</details>
<details id="poke">
    <summary><code style="color: #7694A6">poke</code></summary>

<br>

**Poke**

Equivalent to `git push origin/branchName`

    > poke
</details>
<details id="pop">
    <summary><code style="color: #7694A6">pop</code></summary>

<br>

**Stash Pop**

Equivalent to [`stash pop`](https://git-scm.com/docs/git-stash#Documentation/git-stash.txt-pop--index-q--quietltstashgt). This puts your stashed files back.

usage
</details>
<details id="pull">
    <summary><code style="color: #7694A6">pull</code></summary>

<br>

**Git Pull**

Equivalent to [`git pull`](https://git-scm.com/docs/git-pull)

    > pull
</details>
<details id="push">
    <summary><code style="color: #7694A6">push</code></summary>

<br>

**Git Push**

Equivalent to [`git push`](https://git-scm.com/docs/git-push)

    > push
</details>
<details id="rb">
    <summary><code style="color: #7694A6">rb</code></summary>

<br>

**Git Rebase**

Equivalent to [`git rebase`](https://git-scm.com/docs/git-rebase)

    > rb origin/branchName
</details>
<details id="s">
    <summary><code style="color: #7694A6">s</code></summary>

<br>

**Git Status**

Shorthand equivalent to [`git status`](https://git-scm.com/docs/git-status)

    > s
</details>
<details id="shit">
    <summary><code style="color: #7694A6">shit</code></summary>

<br>

**Shit**

Like the name suggests, you would use this when you make a mistake and need to revert to the latest commit.

    > shit
</details>
<details id="stash">
    <summary><code style="color: #7694A6">stash</code></summary>

<br>

**Git Stash**

Equivalent to [`git stash`](https://git-scm.com/docs/git-stash)

    > stash .
    > stash myFile.js
    > stash myFolder/
</details>
<details id="stashed">
    <summary><code style="color: #7694A6">stashed</code></summary>

<br>

**Show Stashed**

This shows the current stashed files.

    > stashed
</details>
<details id="tug">
    <summary><code style="color: #7694A6">tug</code></summary>

<br>

**Tug**

Equivalent to `git pull origin/branchName`

    > tug
</details>

<br>

<h3 style="display:inline-block"><b>Configuration</b></h3>

<details id="config">
    <summary><code style="color: #7694A6">config</code></summary>

<br>

**Open .profile**

Using this function will open your `.profile` in VS Code, allowing you to make updates to your aliases and functions.

```
> config
```
</details>

<details id="reload">
    <summary><code style="color: #7694A6">reload</code></summary>

<br>

**Reload .profile**

Using this function will allow you to reload and use any changes made to your `.profile` without needed to close your terminal.
```
> reload
```
</details>