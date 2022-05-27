# Git Alias / Function Documentation

To get started, you will need to add the code [found here](./.profile) to your `.profile` file in your User directory ( `~/` ).away

Once your `.profile` is updated. In your `.zshrc`, or `.bashrc` depending on which you see in your User directory or are currently using, add in the following line to the end of that file:

```
source ~/.profile
```

<h3 style="display:inline-block"><b>Functions</b></h3>

<details id="addkick">
    <summary><code style="color: #7694A6">addkick()</code></summary>

<h3 style="margin-top: 8px;color: #378769">Add Kickoff</h3>

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

<h3 style="margin-top: 8px;color: #378769">Commit. Add. Message. Push.</h3>

This function combines the steps of adding, committing and pushing.

<sub><b style="color: #DE897C">Caution: This will add all unstaged files. If you want to add only specific files, do a manual `git add` of the files you want, and then use the [cmp](#cmp) function</b></sub>

    > camp "My commit message"
</details>
<details id="cmp">
    <summary><code style="color: #7694A6">cmp()</code></summary>

<h3 style="margin-top: 8px;color: #378769">Commit. Message. Push.</h3>

Use this function to commit and push already staged files. If no files are staged, `git add` the files you want to commit. If you want to commit all files, use the [camp](#camp) function

    > cmp "My commit message"
</details>
<details id="gwtn">
    <summary><code style="color: #7694A6">gwtn()</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Worktree New</h3>

For adding a new worktree. This function will create the worktree based on the latest, if any, existing GitHub code, installs npm, and does an initial push of the branch if it isn't already set up. Once you run this command, you will be ready to work on this worktree. This will work both existing and non-existing branches.

    > gwtn projectname
</details>
<details id="start">
    <summary><code style="color: #7694A6">start()</code></summary>

<h3 style="margin-top: 8px;color: #378769">Start Kickoff</h3>

Running this function will run `gulp` in the styles folder of your current branch. If it can't find a "style" or "styles" folder anywhere in the project, this will not run.

You can specify the location to run gulp by adding it after `start`

    > start

or specify

    > start myfolder/styling
</details>
<details id="stats">
    <summary><code style="color: #7694A6">stats()</code></summary>

<h3 style="margin-top: 8px;color: #378769">Statistics</h3>

Using this shows you, by default, the last 50 commits made to the repo.

You can specify how many results you want to see by adding `-number` after `stats`

    > stats

or specify

    > stats -10
</details>

<h3 style="display:inline-block"><b>Aliases</b></h3>

<details id="add">
    <summary><code style="color: #7694A6">add</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Add</h3>

Equivalent to `git add`

    > add .
    > add file.html
    > add folder/
</details>
<details id="back">
    <summary><code style="color: #7694A6">back</code></summary>

<h3 style="margin-top: 8px;color: #378769">Go Back</h3>

This will take you back one commit in time.

    > back
</details>
<details id="branch">
    <summary><code style="color: #7694A6">branch</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Branch</h3>

Equivalent to `git branch`

    > branch myBranch
</details>
<details id="branches">
    <summary><code style="color: #7694A6">branches</code></summary>

<h3 style="margin-top: 8px;color: #378769">List Branches</h3>

This will return a list of all branches in the current repo.

    > branches
</details>
<details id="cam">
    <summary><code style="color: #7694A6">cam</code></summary>

<h3 style="margin-top: 8px;color: #378769">Commit. Add. Message.</h3>

Using this will add and commit, with a message, all the untracked files in your branch. If you don't want to commit all files, use the normal `add`, `commit -m` method.

    > cam "My commit message"
</details>
<details idch">
    <summary><code style="color: #7694A6">ch</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Checkout</h3>

Equivalent to `git checkout`

    > ch branch-name
</details>
<details id="chr">
    <summary><code style="color: #7694A6">chr</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Checkout Root</h3>

Equivalent to `git checkout root`

    > chr
</details>
<details id="chsb">
    <summary><code style="color: #7694A6">chsb</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Checkout starter_branch</h3>

Equivalent to `git checkout starter_branch`

    > chsb
</details>
<details idcm">
    <summary><code style="color: #7694A6">cm</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Commit</h3>

Equivalent to `git commit`

    > cm -m "My commit message"
</details>
<details id="fetch">
    <summary><code style="color: #7694A6">fetch</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Fetch</h3>

Equivalent to `git fetch`

    > fetch
</details>
<details id="fuck">
    <summary><code style="color: #7694A6">fuck</code></summary>

<h3 style="margin-top: 8px;color: #378769">Fuck</h3>

As the name suggests, this is when you've made a terrible oopsie and need to revert back to the `origin/master` branch.

<sub><b style="color: #DE897C">Caution: This is a HARD reset. It will delete all uncommitted work.</b></sub>

    > fuck
</details>
<details id="grs">
    <summary><code style="color: #7694A6">grs</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Reset</h3>

Equivalent to `git reset`

    > grs origin/mybranch
</details>
<details id="grv">
    <summary><code style="color: #7694A6">grv</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Remote -v</h3>

Equivalent to `git remote -v`.

Use this alias to view the remotes you have referrenced on your machine.

    > grv
</details>
<details id="gwt">
    <summary><code style="color: #7694A6">gwt</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Worktree</h3>

Equivalent to `git worktree`

    > gwt add mybranch
</details>
<details id="gwta">
    <summary><code style="color: #7694A6">gwta</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Worktree Add</h3>

Equivalent to `git worktree add`

    > gwta mybranch
</details>
<details id="gwtl">
    <summary><code style="color: #7694A6">gwtl</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Worktree List</h3>

Lists all worktrees

    > gwtl
</details>
<details id="gwtr">
    <summary><code style="color: #7694A6">gwtr</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Worktree Remove</h3>

Equivalent to `git worktree remove`

    > gwtr /path/to/branchName
</details>
<details id="peek">
    <summary><code style="color: #7694A6">peek</code></summary>

<h3 style="margin-top: 8px;color: #378769">Peek</h3>

Using this alias allows you to view, by default, the last 20 commits on your current branch.

Very similarly to [stats](#stats), you can specify how many commits you would like to see.

    > peek

or specify

    > peek -5
</details>
<details id="poke">
    <summary><code style="color: #7694A6">poke</code></summary>

<h3 style="margin-top: 8px;color: #378769">Poke</h3>

Equivalent to `git push origin/branchName`

    > poke
</details>
<details id="pop">
    <summary><code style="color: #7694A6">pop</code></summary>

<h3 style="margin-top: 8px;color: #378769">Stash Pop</h3>

Equivalent to `stash pop`. This puts your stashed files back.

usage
</details>
<details id="pull">
    <summary><code style="color: #7694A6">pull</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Pull</h3>

Equivalent to `git pull`

    > pull
</details>
<details id="push">
    <summary><code style="color: #7694A6">push</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Push</h3>

Equivalent to `git push`

    > push
</details>
<details id="rb">
    <summary><code style="color: #7694A6">rb</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Rebase</h3>

Equivalent to `git rebase`

    > rb origin/branchName
</details>
<details id="s">
    <summary><code style="color: #7694A6">s</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Status</h3>

Shorthand equivalent to `git status`

    > s
</details>
<details id="shit">
    <summary><code style="color: #7694A6">shit</code></summary>

<h3 style="margin-top: 8px;color: #378769">Shit</h3>

Like the name suggests, you would use this when you make a mistake and need to revert to the latest commit.

    > shit
</details>
<details id="stash">
    <summary><code style="color: #7694A6">stash</code></summary>

<h3 style="margin-top: 8px;color: #378769">Git Stash</h3>

Equivalent to `git stash`

    > stash .
    > stash myFile.js
    > stash myFolder/
</details>
<details id="stashed">
    <summary><code style="color: #7694A6">stashed</code></summary>

<h3 style="margin-top: 8px;color: #378769">Show Stashed</h3>

This shows the current stashed files.

    > stashed
</details>
<details id="tug">
    <summary><code style="color: #7694A6">tug</code></summary>

<h3 style="margin-top: 8px;color: #378769">Tug</h3>

Equivalent to `git pull origin/branchName`

    > tug
</details>

<br>

<h3 style="display:inline-block"><b>Configuration</b></h3>

<details id="config">
    <summary><code style="color: #7694A6">config</code></summary>

<h3 style="margin-top: 8px;color: #378769">Open .profile</h3>

Using this function will open your `.profile` in VS Code, allowing you to make updates to your aliases and functions.

```
> config
```
</details>

<details id="reload">
    <summary><code style="color: #7694A6">reload</code></summary>

<h3 style="margin-top: 8px;color: #378769">Reload .profile</h3>

Using this function will allow you to reload and use any changes made to your `.profile` without needed to close your terminal.
```
> reload
```
</details>