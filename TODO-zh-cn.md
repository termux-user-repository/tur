# Some TODOs about TUR

PS: 写这个文档的目的是为了记录一下，马上开学了，开学后估计会很忙，这些功能怕不是要一直咕咕咕。希望自己能有足够的精力来维护好这个仓库吧。

PPS: 此文档暂时用中文编写，如果你乐意翻译，请提交 Pull Request，万分感谢。

## TODO List

PS: 下面所列出的待办事项并没有先后顺序，完全是想到什么写什么...

[ ] `dists`: 修复版本比较中的 Bug

[ ] `dists`: 添加删除重复包的功能

[ ] `electron-builder`: 添加额外的 `distribution` 而不是直接到 `tur-packages` 中。随着 `electron` 的版本更新，直接添加到 `tur-packages` 会导致 Release 文件过大，这显然不太合适。

[ ] `electron-builder`: 开启 electron 的自动更新提示。目前的想法是和官方包主仓库一样，采用一个专门的 workflow 去检查，如果有更新不尝试更新，直接创建一个 Issue 然后等待手动解决。

[ ] `pypi`: 更改管理方式。目前的想法是将不同版本的包放在不同的分支里，例如 `python3.8-main` 分支存放 `python3.8` 版本的包，`main` 分支与官方仓库的 Python 版本对齐。为了启用自动更新，名字类似于 `python$PY_MAJRO_VER-$PKG_NAME` 的包应当总是最新版本的，其余旧版本的包应当类似于 `python$PY_MAJOR_VER-$PKG_NAME-$PKG_VER`。

[ ] `tur-avd`: 这是我在 [Issue 43](https://github.com/termux-user-repository/tur/issues/43) 提到的第四种方法，打算采用安卓模拟器来构建一些包，比如 `r-base`，这个包不仅不能交叉编译，也不能在 termux-docker 下构建。当前版本的安卓模拟器好像不能正常启动 arm64 的镜像，不知道为什么。除了这个问题以外，MacOS 怎么全局使用 GNU 的 coreutils 也是一个问题。

[ ] `tur`: 如何处理越来越多的多版本软件？例如 libllvm 和 php，总不能一股脑地全放在 tur 文件夹里吧。

[ ] `tur-nightly`: 想用这个来提供一些 nightly 的软件更新构建，暂时还没想好怎么搞，以后再说吧。

目前想到的就是这么多，具体以后想到了再加吧。
