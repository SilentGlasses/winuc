<img align="left" width="75" height="75" src="winuc.png">

# Windows Ultimate Configurator

*For everyone tired of Microsoft telling them their perfectly good computer isn't good enough for Windows 11.*

Look, Windows 11 has some nice features, but Microsoft's hardware requirements are pretty ridiculous. This tool let's you have control over your own computer. Whether you're running older hardware that works just fine *but Microsoft says it doesn't*, or you just want Windows to stop spying on you and actually run fast, this tool has what you need.

> [!CAUTION]
> - **This tool modifies Windows registry settings and system configuration**.
> - While all changes use standard Windows mechanisms, you should understand what each option does before applying it.
> - Some options *particularly in the bypass category* are specifically designed to work around Microsoft's intended behavior.
> - **Use at your own discretion**.
> - **Always have a backup strategy**.

## Why Windows 11 Requirements Hurt Users, and the Planet

Microsoft’s aggressive hardware requirements don’t just inconvenience users—they create larger problems:

- **Unnecessary E-Waste**: Millions of capable PCs are blocked from upgrading, pushing users toward buying new hardware and adding to global electronic waste.
- **Hidden Costs**: Users face expensive, forced upgrades even when their current systems still work perfectly fine.
- **Environmental Toll**: Manufacturing new computers consumes rare materials, water, and energy, meaning more carbon emissions for no real gain.
- **Artificial Limitations**: These restrictions don’t always translate to meaningful performance or security improvements. *They’re corporate policy and greed masquerading as necessity and security*.

### Microsoft’s Requirements vs. Real-World Performance

| Aspect                   | Windows 11 Official Requirements | With Bypass / Optimization  |
|--------------------------|----------------------------------|-----------------------------|
| **CPU**                  | 8th Gen Intel / AMD Ryzen 2000+  | Works on older CPUs         |
| **TPM 2.0**              | Mandatory                        | Optional (can be bypassed)  |
| **Secure Boot**          | Mandatory                        | Optional (user-controlled)  |
| **Hardware Longevity**   | Forces upgrades                  | Extends usable lifespan     |
| **Environmental Impact** | Increased e-waste                | Reduces e-waste, re-use     |

- **~240 million PCs** worldwide are considered incompatible with Windows 11, despite being fully functional.
- The world generates **over 50 million metric tons of e-waste annually** — equivalent to throwing away 1,000 laptops every second.
- Extending a device’s lifespan by just **2 years** can reduce the total carbon footprint by **up to 30%**.


>[!TIP]
> Green House Gases (GHG) emissions from e-waste have **increased by ~53% over six years**; extending usable life helps slow that trend.

## Or Just Use Linux Instead?

To be honest, sometimes you need Windows for specific software or work requirements. But if you're mainly browsing the web, writing documents, or doing general computer stuff, Linux might be the better answer.

Here's the thing: while Microsoft is making Windows more **restrictive** and **invasive** with every update, Linux is going the opposite direction. With Linux, you get:

- **Actually Free Software**: Not free with hidden costs and data harvesting, just genuinely free. The entire OS, plus thousands of applications, cost you nothing and come without strings attached.
- **Your Computer, Your Rules**: No forced updates, no telemetry you can't disable, no Microsoft account requirements. You decide what runs on your machine and when.
- **Privacy by Default**: Linux distributions don't phone home, track your usage, or build advertising profiles. What you do on your computer stays on your computer.
- **Security That Works**: Regular security updates without the bloatware. No Windows Defender slowing everything down.
- **Runs on Anything**: That incompatible hardware Microsoft rejected? Linux will probably make it run better than it ever did on Windows. I'm literally writing this on a machine that Microsoft says can't run Windows 11.
- **Real Support Community**: When something breaks, you get help from people who actually know the system, not chatbots reading from scripts.

Distributions like **Fedora**, **Linux Mint**, or **Pop!_OS** are genuinely easier to use than Windows 11 for most people. The learning curve exists, but it's way smaller than dealing with Microsoft's constant *improvements* that make everything worse.

Sure, gaming used to be Linux's weak spot, but with Steam's Proton and native Linux games, most stuff just works now. And if you absolutely need Windows for something specific, you can run it in a virtual machine with all the spying turned off.

**Bottom line**: If Microsoft's hardware requirements pushed you here, maybe that's a sign it's time to try something that respects both your hardware and your privacy.

## Safety & Compatibility

All changes are made through standard Windows registry modifications, nothing sketchy or nefarious. The tool creates registry paths as needed and handles both `string` and `DWORD` values correctly.

That being said, some changes like disabling System Restore or User Access Control (UAC) do reduce system protection, so think about what you actually need. Most people will want the bypass and privacy options, with performance and appearance tweaks being personal preference.

>[!TIP]
> By keeping older hardware running longer, you’re not just saving money, you’re helping reduce electronic waste and lowering the environmental footprint of constant forced upgrades.

## What Does This Do?

This tool does two main things: it lets you install Windows 11 on hardware Microsoft doesn't want you to use, and it fixes a lot of the annoying defaults Microsoft ships with.

The interface is clean and actually respects your Windows theme. I've organized everything into logical categories with individually selectable options. When you hover over any option, you get a plain English explanation of what it actually does - no corporate speak or technical jargon.

You can either apply changes directly to your current system, or generate an unattended install file that does everything automatically during Windows installation. Both work great.

>[!TIP]
> If you’re running Windows 11 on older hardware, you’re extending the usable life of your device, avoiding premature obsolescence and helping cut down on the cycle of unnecessary e-waste.

## What's Inside

- **Bypass the BS**: Install Windows 11 on any computer that actually works fine
- **Stop the Spying**: Turn off Microsoft's constant data collection
- **Actually Make it Fast**: Performance tweaks that make a real difference
- **Gaming that Works**: Less lag, better frame rates, fewer interruptions
- **Better Networking**: Faster internet without Microsoft's *helpful* interference
- **System Cleanup**: Get rid of Xbox apps and other junk you didn't ask for
- **Fix the Interface**: Bring back the parts of Windows 10 that actually worked

## Quick Start

### Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Administrator privileges is needed for registry changes

### Running the Tool

1. Launch PowerShell with **Run as administrator**
2. Run:
```
irm https://raw.githubusercontent.com/SilentGlasses/winuc/main/winuc.ps1 | iex
```

That's it. The GUI opens up and you can start choosing what you want to fix.

## Using the Unattended Install File

If you're doing a fresh Windows 11 install, you can skip all the post-install tweaking by generating an unattended install file. This is especially useful if you're installing on *unsupported* hardware or setting up multiple machines.

### What You'll Need
- A Windows 11 ISO file
- A USB drive (8GB+) or DVD
- A tool to create bootable media like Rufus, Ventoy, or even Windows' own Media Creation Tool

### Step-by-Step Process

- **Generate the unattended file**:
    - Run `winuc.ps1` as described above
    - Select all the options you want
    - Click **Generate** instead of **Apply**
    - This creates `autounattend.xml` in the same folder
- **Prepare your installation media**:
    - Create a bootable USB drive with your Windows 11 ISO
    - **Important**: Don't eject the USB yet!
- **Add the unattended file**:
    - Copy `autounattend.xml` to the **root** of your USB drive or the same level as the `setup.exe` file
    - That's it, Windows will find and use it automatically
- **Install Windows**:
    - Boot from your USB drive
    - Windows will automatically apply all your selected tweaks during installation
    - No manual configuration needed after install

### What Happens During Install

- **Hardware bypasses** are applied immediately so installation can proceed on *unsupported* systems
- **Privacy settings** are configured before Windows even finishes installing
- **Performance tweaks** are applied during first boot
- **Bloatware removal** happens automatically
- You get a clean, optimized Windows 11 without the usual setup hassles

### Pro Tips

- **Test first**: Try the unattended install in a virtual machine before using it on real hardware
- **Keep backups**: Save your `autounattend.xml` file so you can reuse it for other installs
- **Multiple versions**: Generate different files for different use cases like a gaming rig vs. work machine
- **USB persistence**: If using Ventoy, you can keep multiple unattended files and choose which one to use

>[!NOTE]
> The unattended file includes bypass options that let you install on older hardware, plus privacy and performance settings that take effect immediately. It's like having a system administrator configure everything perfectly while you grab coffee or tea.

## What's Inside

### Windows 11 Bypass Options

Because your 2017 laptop is fine, actually.

- Skip the TPM 2.0 nonsense
- Ignore Secure Boot requirements
- Install on computers with *only* 3GB of RAM
- Use that Intel i5 from 2016 that still works perfectly
- Install on smaller drives (under 64GB)
- Skip the forced internet connection during setup
- Create a local account instead of being forced into Microsoft's ecosystem

### Privacy & Security

Stop Windows from tattling on you.

- Turn off the constant *diagnostic* data collection (aka spying)
- Disable Cortana because nobody asked for a voice assistant
- Stop Windows from creating an advertising profile of you
- Actually control which apps can use your camera and microphone
- End those annoying *How are we doing?* popup surveys
- Prevent Microsoft from tracking everything you do
- Keep the useful security features (firewall, etc.) but remove the privacy invasions

### Performance Improvements

Make your computer actually feel responsive again.

- Prioritize the stuff you're actually using instead of background nonsense
- Turn off the fancy animations that just slow things down
- Stop Windows from constantly indexing every file you have
- Optimize settings for SSDs *because it's 2025, not 2005*
- Remove the artificial delays Microsoft adds to make things *feel* smoother
- Cut the startup lag that makes right-click menus take forever

### Gaming Optimizations

For when you want games to actually run well.

- Turn off Xbox Game Bar because it's just popup spam during games
- Enable the Game Mode that actually works
- Let your graphics card handle scheduling instead of Windows
- Stop Windows from *optimizing* fullscreen games *it doesn't help*
- Remove network delays that add lag to online games

### Network Enhancements

Stop Windows from messing with your internet connection.

- Prevent your computer from sharing Windows updates with strangers
- Use Cloudflare DNS instead of your ISP's slow servers
- Remove the artificial 20% bandwidth limit Windows reserves *just in case*
- Let your network connection actually use the speed you're paying for
- Stop Windows from throttling network traffic for no good reason

### System Cleanup

Remove the junk Microsoft installs by default.

- Stop Xbox apps from installing themselves
- Turn off OneDrive integration if you don't want it
- Prevent Windows Store from updating apps you didn't ask for
- Automatically clean up temp files that pile up over time
- Turn off hibernation to free up several gigabytes of disk space
- Optionally disable System Restore if you handle your own backups

### Appearance Tweaks

Bring back the interface elements that actually worked.

- Get the full right-click menu back *not the dumbed-down Windows 11 version*
- Move taskbar icons to the left
- Show file extensions because hiding them was always bad
- Always show hidden files
- Hide that Task View button nobody uses

## If Something Goes Wrong

- **Execution policy errors**: PowerShell is being paranoid. Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` first
- **Registry access denied**: You forgot to run PowerShell as administrator
- **Changes don't take effect**: Windows is stubborn. Reboot, or at least log out and back in
- **Still having issues**: Most of these are just registry changes, so you can undo them manually if needed

## Want to Help?

- Found something broken or have ideas for more fixes?
    - The code is pretty straightforward, just add your tweaks to the `$Global:enhancementOptions` section and submit a pull request.
- Or open an issue if you're not into coding.

## License

MIT License ... create a fork and do whatever you want with it.

## References

- [Life-Cycle/Production Impact of Notebooks / Laptops](https://twosides.info/UK/the-environmental-cost-of-short-notebook-and-laptop-lifetimes-revealed-in-german-study/)
- [Framework Laptop 2022 (Fraunhofer IZM report)](https://downloads.frame.work/resources/Framework-Life-Cycle-Report.pdf)
- [Microsoft - Windows 11 Specs and System Requirements](https://www.microsoft.com/en-us/windows/windows-11-specifications)
- [EPA - Sustainable Management of Electronics](https://www.epa.gov/international-cooperation/cleaning-electronic-waste-e-waste)
- [United Nations - Global E-waste Monitor](https://ewastemonitor.info/)
- [THE GLOBAL E-WASTE MONITOR 2024 - 13.8 billion kg of e-waste were generated worldwide in 2022](https://api.globalewaste.org/publications/file/297/Global-E-waste-Monitor-2024.pdf)
