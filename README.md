# PrusaSlicer.AppImage

### Download

Latest: https://github.com/gneiss15/PrusaSlicer.AppImage/releases/latest

All Releases: https://github.com/gneiss15/PrusaSlicer.AppImage/releases

### Background

According to the [release notes](https://github.com/prusa3d/PrusaSlicer/releases/tag/version_2.9.0-alpha1) for PrusaSlicer 2.9.0-alpha1, Prusa would want a PrusaSlicer AppImage to:

* Bundle all necessary dependencies, including libraries such as glibc or webkit. - ✅ **DONE** by bundling _all_ dependencies of the application rather than _just the depencencies that cannot be reasonably assumed to be part of each target system_
* Not require specific versions of system libraries, such as libfuse, to be present on the target system. - ✅ **DONE** by using a static AppImage runtime that does not use libfuse from the system, and bundling _all_ dependencies of the application
* Be able to run on multiple Linux distributions without requiring extensive maintenance. - ✅ **DONE** by the above
* Allow for easy building and distribution of multiple architectures, such as x86_64 and aarch64. - ✅ **DONE** by using tooling that supports these architectures (e.g., Docker)
* Not require building on older distributions for compatibility reasons. - ✅ **DONE** by bundling _all_ dependencies of the application
* Provide a seamless user experience, including desktop integration and application updates. - (☑️) [Done by PrusaSlicer since 2.4](https://github.com/prusa3d/PrusaSlicer/blob/ae97d00c34258f85b98fb000c131162863424a04/doc/How%20to%20build%20-%20Linux%20et%20al.md?plain=1#L121). Alternatively, users can use an optional [desktop integration](https://github.com/AppImageCommunity/awesome-appimage?tab=readme-ov-file#desktop-integration) tool (but not desirable in all cases, see below)
* Offer a sandboxing mechanism to control application permissions. - (☑️) **OPTIONAL** using a third party sandbox (but not desirable in all cases, see below)

So far I have tested the AppImage on
* Windows 11 with WSL2 in a Debian environment ✅
* Ubuntu Studio 20.04.3 LTS (Focal Fossa) on hardware with Intel graphics ✅
* Fedora Linux 38 (KDE Plasma) on hardware with Intel graphics ✅
* Fedora Workstation 40 (GNOME) on VirtualBox ✅
* Manjaro Linux XFCE 24.1.2-241104 (like Arch Linux) on VirtualBox ✅
* Chimera Linux 20241027 (which uses musl libc instead of glibc and doesn't use many parts of GNU) on VirtualBox ✅
* NixOS 24.05.6668 (KDE Plasma) (which doesn't have `/usr` populated) on VirtualBox ✅
* Ubuntu 16.04.7 LTS (Xenial Xerus) (8 years old) on VirtualBox (☑️) with minor graphical glitches

Please let me know your experience with using this AppImage, mentioning your Linux distribution and version.

### Details

Prusa Research has been offering PrusaSlicer for Windows, Mac, and Linux from their own download page and from GiHub Actions for quite some while. For Linux, Prusa has been using the AppImage format for years, as it provides a way to have one convenient download for various Linux distributions. This has has been working well for many happy users over the years. 

However, the [release notes](https://github.com/prusa3d/PrusaSlicer/releases/tag/version_2.9.0-alpha1) for PrusaSlicer 2.9.0-alpha1 state that Flatpak will be used as an official way to distribute PrusaSlicer for Linux in the future.
While I fully respect Prusa Research's freedom to distribute their software in every way they wish (after all, this is the main point of the AppImage project), the release notes make some claims about the AppImage format that require a closer look because they are not (or no longer) factually accurate:

* **It is claimed that AppImage is not designed to bundle "everything" and requires assumptions about the target system.** AppImage, first and foremost, is a self-mounting disk image that merely mounts itself and runs whatever the aplication author has put inside. In that regard, it is not unlike a `.zip` file. In deciding how much to bundle privately vs. how much to use from the target system, an application author is at liberty to make a tradeoff decision between size and robustness. Traditionally, most application developers wanted to bundle only those dependencies of an application _that could not safely be assumed to come with all supported mainstream desktop Linux distributions_. Since Linux distributions apparently are [not reaching universal consensus](https://gitlab.com/probono/platformissues) on how to do even basic things (e.g., in which location to put certain files), it is not easy to find a "common ground" that can be assumed to be part of every supported target system. A common-sense approach that has worked reasonably well for many is to target the oldest still-supported Ubuntu LTS release. **However**, this is not the only one to do things, and the application developer might also decide to bundle _all dependencies of an application, full stop_.
* **It is claimed that AppImage requires manual decision-making and testing on all targeted Linux distributions.** While true, that decision can very well be to bundle _everything_ the application needs to run. This will result in a larger download size (although not as extreme as with Flatpak, as explained below).
* **It is claimed that that some libraries may be "almost or completely" impossible to bundle (e.g., glibc or webkit).** Tools like go-appimage or sharun exist that entirely automate the handling of glibc. As for webkit2gtk, some manual steps are currently needed because that software is not built with relocatability in the filesystem in mind (in other words, it uses compiled-in hardcoded paths). However, this can be solved by some trivial patching (or submitting an upstream fix).
* **It is claimed that AppImage requires a specific version of libfuse to be present on the target system.** While this used to be the case with older versions of the AppImage runtime (a tiny piece of software that is part of evey AppImage - not to be confused with the large Flatpak runtimes), it is no longer the case when you use a [static runtime](https://github.com/AppImage/type2-runtime) that does not rely on any libraries from the target system, including libfuse. In fact, today there are several static runtiems from different authors, one even written in Rust. For systems with no FUSE support at all, an AppImage can be extracted (similar to a `.zip` file) using the `--appimage-extract` command line option. For this, no FUSE is needed at all.
* **It is claimed that Using old glibc for compatibility reasons forces building on older distros.** This is not an inherent limitation of AppImage. It is merely a consequence of application developers wanting to privately bundle only the dependencies that _cannot reasonably assumed to be part of every mainstream Linux distribution_. When you develop against an OS, then usually your users will need that OS version or a newer version in order to run your application. The only way around this is to _bundle everything_ - which is what Flatpak does, and is what an application author can choose to do with AppImage as well.
* **It is claimed that Flatpak solves the dependency hell problem by building against a defined runtime.** While true, this means that on top of the user's Linux distribution, essentially the whole stack is installed a second time (e.g., in the case of PrusaSlicer, all of GNOME even if you are not using GNOME at all). And the runtime is definded by _someone_, not by the application author. There are some applications that require certain versions of (patched) dependencies. This is easy with AppImage but not with Flatpak.
* **It is claimed that Flatpak provides better desktop integration and application updates.** Depending on the use case, this may be an advantage or a disadvantage. For example, users wanting to try out the latest alpha version don't neessarily want that version to be integrated into the desktop, and certainly don't want the previous alpha to go away when a newer one is downloaded. With AppImage, users can have as many versions around as they like to. For example, having an AppImage would be especially be beneficial for each of the development branches in the PrusaSlicer project, as it would allow testers to test the branches easily.
* **It is claimed that Flatpak offers sandboxing and permission control.** This is possible for AppImages as well with third party sandboxes, but with unlike Flatpak, it is not mandatory and is not forced upon users.

The [release notes](https://github.com/prusa3d/PrusaSlicer/releases/tag/version_2.9.0-alpha1) for PrusaSlicer 2.9.0-alpha1 also state some downsides of using Flatpak:

> First, make sure you have flatpak installed and Flathub correctly set up. You can follow the steps at https://flatpak.org/setup/.

This is not necessary with AppImage. The AppImage format is specifically designed so that users don't need to install anything else first, and do not need to have root permissions.

> Please understand that publication of PrusaSlicer on Flathub has to be preceded by the publication on our GitHub. This means that there will always be certain delay (typically couple of hours) before the new release shows up on Flathub. This is the expected behaviour, the extra time is needed to build the Flathub binary.

With AppImage, builds can be published immediately as part of the regular build pipeline. The builds are available immediately.

> Flatpak also provides better user experience regarding desktop integration and application updates, and it is able to control permissions that the applications have through its sandboxing mechanism. Although this may not be appealing to all Linux users, we believe that these points are valuable to most.

"Better" is subjective. Some users want one single file which can be downoaded and run, without the need to install anything, and without affecting any other versions that may already be on the system. Some users might be running a Linux Live ISO which is not even installed on the machine. Some users don't even have root permissions on the system they are using. AppImage delivers in these situations. [AppImageUpdate](https://github.com/AppImageCommunity/AppImageUpdate) allows for very efficient delta updates. And with AppImage, sandboxing is optional but possible for users who want it.

> The biggest complain people have about Flatpak is that it downloads too much data to run a single application (although a runtime is only downloaded once for all applications that rely on it).

According to a scientific experiment, installing PrusaSlicer using Flatpak downloads 854 MB.

Flatpak download sizes are enormous, because whole runtimes (e.g., the entirety of GNOME) are downloaded even though only a tiny fraction of it might be required by the application. In contrast, with AppImage the developer can bundle only the few files the application actually needs to run and not rely on monolithic third-party runtimes.

An AppImage bundling PrusaSlicer with _all_ dependencies it needs to run is 201 MB, so 1/4 the size of the same application installed by Flatpak and the dependencies it pulls in.

> We understand that the decision may make some people angry and raise questions about why we are leaving something that "just works" (the AppImage).

Luckily, it's not either-or: AppImage and Flatpak serve different purposes for different target groups (portable single-file applications vs. installed applications). So why not have both?

### References

* https://github.com/prusa3d/PrusaSlicer/issues/13653
* https://github.com/prusa3d/PrusaSlicer/issues/13376 
* https://github.com/prusa3d/PrusaSlicer/issues/13361 (no more need for two separate AppImages)
* https://github.com/prusa3d/PrusaSlicer/issues/12984 (libwebkit2gtk-4.0 is now bundled)
* https://github.com/prusa3d/PrusaSlicer/issues/12835 (libwebkit2gtk-4.0 is now bundled)
* https://github.com/prusa3d/PrusaSlicer/issues/12922 (_all_ libraries are now bundled)
