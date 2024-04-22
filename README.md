# Git Aliases Documentation

## Table of Contents
- [Introduction](#introduction)
- [Installing](#installing)
- [Updating aliases](#updating-aliases)
- [Functions](#functions)
#

<br>

# Introduction
A bunch of helpful aliases for a fast, efficient workflow. Most of the important functions are listed below. Take a look!

# Installing
### 1) Loading the aliases
You will first need to make sure you have a `~/.profile` file. To ensure you do, run the command:
```sh
touch ~/.profile
```

In your `.zshrc`, or `.bashrc` depending on which you see in your User directory or are currently using, open it by running `open ~/.zshrc` or `open ~/.bashrc`.

>__Note:__
If you don't know which one you are using, run `echo $0`. This should display "`-zsh`" or "`-bash`". Use whichever one displays or install and choose your own. You can follow [these steps](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH) to install zsh.

Then, add in the following line to the end of that file:
```sh
source ~/.profile
```
This ensures the aliases are loaded for every terminal session.

### 2) In your terminal, run the following code to open up your `.profile` in your default editor:
To get started, you will need to add the code in [this .profile file](./.profile) to your `.profile` file in your User directory ( `~/` ) ( `~/` ). 
```sh
open ~/.profile
```

Replace all, if any, content with [this .profile file](./.profile) in this repo.
After you put the latest code in your `.profile`, make sure you update the configuration variables.
>__Example__: If your CWS folder is in your User Directory ( `~/` ), you would make `JVPATH` equal `~/CWS/`.

### 3) Save your file, then run:

```sh
source ~/.profile
```

<br>

# Updating aliases
### 1) In your terminal, run:

```sh
config
```

to open up your `.profile`, and replace what you have with the code in the `.profile` in this repo.

After you put the latest code in your `.profile`, make sure you update the `JVPATH` variable to reflect the path to your CWS folder.

If your CWS folder is in your User Directory ( `~/` ), for example, you would make `JVPATH` equal `~/CWS/`.

### 2) Save your file, then open a new Shell, or run:

```sh
reload
```

<br><br>

## Functions

<details id="addStyles">
    <summary><code>addStyles()</code></summary>

<br>

**Add Styles**

Using this function will allow you to get the latest Kickoff code into any project.
You can specify where you would like to put it by adding in the path after `addStyles`, or you can go to that location in your terminal and run `addStyles`.

Arguments:
| Name | Function | Optional |
| ---- | -------- | :------: |
| branch_name | Name of directory to store kickoff. If empty, uses current directory. | ✓ |

Examples:

```sh
git:(<branch_name>) $ addStyles

git:(<branch_name>) $ addStyles ./myfolder
```
</details>
<details id="camp">
    <summary><code>camp()</code></summary>

<br>

**Commit. Add. Message. Push.**

This function combines the steps of adding, committing and pushing. It also allows for tagging, if you feel so inclined. You can specify which branch you want to push, or `cd` into that branch and use the function without specifying.

<sub class="warn"><b>Caution: This will add all unstaged files. If you want to add only specific files, do a manual `git add` of the files you want, and then use the [cmp](#cmp) function or [cam](#cam) alias</b></sub>

Arguments:
| Name | Function | Optional |
| ---- | -------- | :------: |
| commit_msg | Message for commit. Technically optional, but not recommended to exclude | x |
| -t | Flag for adding a tag | ✓ |
| tag | Value for tag (i.e., v1.0) | ✓ |
| tag_msg | Message for tag | ✓ |
| branch_name | Name of project. If empty, uses current directory. | ✓ |
| -f | Flag for a force push | ✓ |

Examples:

```sh
git:(<branch_name>) $ camp <commit_msg>
git:(<branch_name>) $ camp <commit_msg> -f
git:(<branch_name>) $ camp <commit_msg> <branch_name>
git:(<branch_name>) $ camp -t <tag>
git:(<branch_name>) $ camp -t <tag> <commit_msg>
git:(<branch_name>) $ camp -t <tag> -m <tag_msg>
git:(<branch_name>) $ camp -t <tag> -m <tag_msg> <commit_msg>
```
</details>
<details id="cmp">
    <summary><code>cmp()</code></summary>

<br>

**Commit. Message. Push.**

Use this function to commit and push already staged files. If no files are staged, `git add` the files you want to commit. If you want to commit all files, use the [camp](#camp) function

Arguments:
| Name | Function | Optional |
| ---- | -------- | :------: |
| commit_msg | Message for commit. | x |

Example:

```sh
git:(<branch_name>) $ cmp <commit_msg>
```

</details>
<details id="gwtn">
    <summary><code>gwtn()</code></summary>

<br>

**Git Worktree New**

`gwtn` is used to create a new worktree for a Git project. It accepts several options and a  `branch`  argument.

For adding a new worktree. This function will create the worktree based on the latest, if any, existing GitHub code, installs npm, and does an initial push of the branch if it isn't already set up. Once you run this command, you will be ready to work on this worktree. This will work with both existing and non-existing branches.

Arguments:
| Name | Function | Required | Optional |
| ---- | -------- | :------: | :------: |
| `branch_name` | Name of branch/project. | ✓ |
| `-h`  or  `--help` | Displays a brief help message explaining the usage and options of the function. |  | ✓ |
| `-s`  or  `--skip-install`  or  `--skip` | Specifies that the installation step should be skipped. |  | ✓ |
| `-no`  or  `--noopen` | Specifies that the worktree should not be opened in VSCode. |  | ✓ |
| `-m`  or  `--make` | Equivalent to calling  `gwtn -s -no` , which skips installation and opening in VSCode. |  | ✓ |
| `--detach` | Creates the local worktree without creating the branch in the origin repository. |  | ✓ |

Examples:

```sh
# create a new worktree named "mybranch"
gwtn mybranch

# displays a brief help message explaining the usage and options
gwtn -h

# create a new worktree named "mybranch" and skip npm installation without creating the branch in the origin repository. 
gwtn mybranch -s --detach

# create a new worktree named "mybranch" without opening the project in VSCode
gwtn mybranch -no

#create a new worktree named "mybranch" with the options to skip installation and not open it in VSCode.
gwtn mybranch -s --noopen

# create a new worktree named "mybranch" and skips both the installation step and opening it in VSCode.
gwtn mybranch -m
# It is equivalent to
gwtn mybranch --skip-install --noopen
```

</details>

<details id="gwtr">
    <summary><code>gwtr()</code></summary>

<br>

**Git Worktree Remove**

For removing a worktree. This function will run by using the current location's branch, or by specifying a branch name. If the branch also needs to be deleted, use the `-d` flag.

Arguments:

| Name | Function | Optional |
| ---- | -------- | :------: |
| -d | Flag to include deleting the branch | ✓ |
| branch_name | Name of branch. If empty, uses current branch. | ✓ |

Examples:

Remove the worktree of the current branch.

```sh
git:(<branch_name>) $ gwtr
git:(<branch_name>) $ gwtr -d
```

Remove the worktree of a specific branch.

```sh
git:(root) $ gwtr <branch_name>
git:(root) $ gwtr -d <branch_name>
```

</details>
<details id="new">
    <summary><code>new()</code></summary>

<br>

**New Project Structure**

Running this function creates an unobtrusive new `starter_branch` folder structure. It will add the `desktop/`, `mobile/`, `images/`, and `styles/` folders, as well as call [addkick](#addkick), so it will add the latest Kickoff code. If any folders of the same name already exist, they will be untouched and no new folder will be created, leaving all previous work safe, but giving us the opportunity to easily work with the latest code and structure.

Example:

```sh
git:(<branch_name>) $ new
```

</details>
<details id="start">
    <summary><code>start()</code></summary>

<br>

**Start Kickoff**

Running this function will find the nearest folder with npm in your current branch, install `npm`, and run `gulp`.


Arguments:

| Name | Function | Required | Optional |
| ---- | -------- | :------: | :------: |
| `-i`  or  `--install-only` | Installs npm in the nearest folder possible |  | ✓ |
| `-s`  or  `--skip-install` | Runs `gulp` in the nearest folder possible |  | ✓ |
| `-d folder_name` or `folder_name` | Specifies a directory to run the commands |  | ✓ |

Examples:

```sh
#install npm in your project's styling
start -i

#run gulp in your project's styling
start -s

#install npm in a specified folder
start -i folder_name
```

</details>
<details id="stats">
    <summary><code>stats()</code></summary>

<br>

**Statistics**

Using this shows you, by default, the last 50 commits made to the repo.

You can specify how many results you want to see by adding `-number` after `stats`

Arguments:
| Name | Function | Optional |
| ---- | -------- | :------: |
| -# | Number of commits to view. Defaults to `-50` | ✓ |

Examples:

```sh
git:(<branch_name>) $ stats

git:(<branch_name>) $ stats -10
```

</details>

<h3><b>Aliases</b></h3>

<details id="add">
    <summary><code>add</code></summary>

<br>

**Git Add**

Equivalent to [`git add`](https://git-scm.com/docs/git-add)

```sh
git:(<branch_name>) $ add .

git:(<branch_name>) $ add file.html

git:(<branch_name>) $ add folder/
```

</details>
<details id="back">
    <summary><code>back</code></summary>

<br>

**Go Back**

This will take you back one commit in time.

```sh
git:(<branch_name>) $ back
```

</details>
<details id="branch">
    <summary><code>branch</code></summary>

<br>

**Git Branch**

Equivalent to [`git branch`](https://git-scm.com/docs/git-branch)

```sh
branch myBranch
```

</details>
<details id="branches">
    <summary><code>branches</code></summary>

<br>

**List Branches**

This will return a list of all branches in the current repo.

```sh
branches
```

</details>
<details id="cam">
    <summary><code>cam</code></summary>

<br>

**Commit. Add. Message.**

Using this will add and commit, with a message, all the untracked files in your branch. If you don't want to commit all files, use the normal `add`, `commit -m` method.

Arguments:
| Name | Function | Optional |
| ---- | -------- | :------: |
| commit_msg | Message for commit. | x |

Example:

```sh
git:(<branch_name>) $ cam <commit_msg>
```

</details>
<details idch">
    <summary><code>ch</code></summary>

<br>

**Git Checkout**

Equivalent to [`git checkout`](https://git-scm.com/docs/git-checkout)

```sh
ch branch-name
```

</details>
<details id="chr">
    <summary><code>chr</code></summary>

<br>

**Git Checkout Root**

Equivalent to `git checkout root`

```sh
chr
```

</details>
<details id="chsb">
    <summary><code>chsb</code></summary>

<br>

**Git Checkout starter_branch**

Equivalent to `git checkout starter_branch`

```sh
chsb
```

</details>
<details idcm">
    <summary><code>cm</code></summary>

<br>

**Git Commit**

Equivalent to [`git commit`](https://git-scm.com/docs/git-commit)

Arguments:
| Name | Function | Optional |
| ---- | -------- | :------: |
| commit_msg | Message for commit. | x |

Example:

```sh
git:(<branch_name>) $ cm -m <commit_msg>
```

</details>
<details id="fetch">
    <summary><code>fetch</code></summary>

<br>

**Git Fetch**

Equivalent to [`git fetch`](https://git-scm.com/docs/git-fetch)

```sh
fetch
```

</details>
<details id="fuck">
    <summary><code>fuck</code></summary>

<br>

**Fuck**

As the name suggests, this is when you've made a terrible oopsie and need to revert back to the `origin/master` branch.

<sub><b>Caution: This is a HARD reset. It will delete all uncommitted work.</b></sub>

```sh
git:(<branch_name>) $ fuck
```

</details>
<details id="grs">
    <summary><code>grs</code></summary>

<br>

**Git Reset**

Equivalent to [`git reset`](https://git-scm.com/docs/git-reset)

```sh
git:(<branch_name>) $ grs origin/<branch_name>
```

</details>
<details id="grv">
    <summary><code>grv</code></summary>

<br>

**Git Remote -v**

Equivalent to [`git remote -v`](https://git-scm.com/docs/git-remote#Documentation/git-remote.txt--v).

Use this alias to view the remotes you have referrenced on your machine.

```sh
grv
```

</details>
<details id="gwt">
    <summary><code>gwt</code></summary>

<br>

**Git Worktree**

Equivalent to [`git worktree`](https://git-scm.com/docs/git-worktree)

```sh
git:(root) $ gwt add mybranch
```

</details>
<details id="gwta">
    <summary><code>gwta</code></summary>

<br>

**Git Worktree Add**

Equivalent to [`git worktree add`](https://git-scm.com/docs/git-worktree#Documentation/git-worktree.txt-addltpathgtltcommit-ishgt)

```sh
git:(root) $ gwta mybranch
```

</details>
<details id="gwtl">
    <summary><code>gwtl</code></summary>

<br>

**Git Worktree List**

Lists all worktrees

```sh
gwtl
```

</details>
<details id="peek">
    <summary><code>peek</code></summary>

<br>

**Peek**

Using this alias allows you to view, by default, the last 20 commits on your current branch.

Very similarly to [stats](#stats), you can specify how many commits you would like to see.

Arguments:
| Name | Function | Optional |
| ---- | -------- | :------: |
| -# | Number of commits to show. Defaults to `-20` | ✓ |

Examples:

```sh
git:(<branch_name>) $ peek

git:(<branch_name>) $ peek -5
```

</details>
<details id="poke">
    <summary><code>poke</code></summary>

<br>

**Poke**

Equivalent to `git push origin/branchName`

```sh
git:(<branch_name>) $ poke
```

</details>
<details id="pop">
    <summary><code>pop</code></summary>

<br>

**Stash Pop**

Equivalent to [`stash pop`](https://git-scm.com/docs/git-stash#Documentation/git-stash.txt-pop--index-q--quietltstashgt). This puts your stashed files back.

usage
</details>
<details id="pull">
    <summary><code>pull</code></summary>

<br>

**Git Pull**

Equivalent to [`git pull`](https://git-scm.com/docs/git-pull)

```sh
git:(<branch_name>) $ pull
```

</details>
<details id="push">
    <summary><code>push</code></summary>

<br>

**Git Push**

Equivalent to [`git push`](https://git-scm.com/docs/git-push)

```sh
git:(<branch_name>) $ push
```

</details>
<details id="rb">
    <summary><code>rb</code></summary>

<br>

**Git Rebase**

Equivalent to [`git rebase`](https://git-scm.com/docs/git-rebase)

```sh
git:(<branch_name>) $ rb origin/branchName
```

</details>
<details id="s">
    <summary><code>s</code></summary>

<br>

**Git Status**

Shorthand equivalent to [`git status`](https://git-scm.com/docs/git-status)

```sh
git:(<branch_name>) $ s
```

</details>
<details id="shit">
    <summary><code>shit</code></summary>

<br>

**Shit**

Like the name suggests, you would use this when you make a mistake and need to revert to the latest commit.

```sh
git:(<branch_name>) $ shit
```

</details>
<details id="stash">
    <summary><code>stash</code></summary>

<br>

**Git Stash**

Equivalent to [`git stash`](https://git-scm.com/docs/git-stash)

```sh
git:(<branch_name>) $ stash .
```

```sh
git:(<branch_name>) $ stash myFile.js
```

```sh
git:(<branch_name>) $ stash myFolder/
```

</details>
<details id="stashed">
    <summary><code>stashed</code></summary>

<br>

**Show Stashed**

This shows the current stashed files.

```sh
git:(<branch_name>) $ stashed
```

</details>
<details id="tug">
    <summary><code>tug</code></summary>

<br>

**Tug**

Equivalent to `git pull origin/branchName`

```sh
git:(<branch_name>) $ tug
```

</details>

<br>

<h3><b>Configuration</b></h3>

<details id="config">
    <summary><code>config</code></summary>

<br>

**Open .profile**

Using this function will open your `.profile` in VS Code, allowing you to make updates to your aliases and functions.

```sh
config
```
</details>

<details id="reload">
    <summary><code>reload</code></summary>

<br>

**Reload .profile**

Using this function will allow you to reload and use any changes made to your `.profile` without needed to close your terminal.
```sh
reload
```
</details>
