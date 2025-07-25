<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![project_license][license-shield]][license-url]
<!-- [![LinkedIn][linkedin-shield]][linkedin-url] -->



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <!-- <a href="https://github.com/VeeLume/sc-mapper-dart">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

<h3 align="center">SC Mapper</h3>

  <p align="center">
    A StreamDeck Plugin to quickly map Star Citizen actions
    <br />
    <a href="https://github.com/VeeLume/sc-mapper-dart"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/VeeLume/sc-mapper-dart">View Demo</a>
    &middot;
    <a href="https://github.com/VeeLume/sc-mapper-dart/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/VeeLume/sc-mapper-dart/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <!-- <li> -->
      <!-- <a href="#about-the-project">About The Project</a> -->
      <!-- <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul> -->
    <!-- </li> -->
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <!-- <li><a href="#contact">Contact</a></li> -->
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
<!-- ## About The Project -->


<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

<!-- <p align="right">(<a href="#readme-top">back to top</a>)</p> -->



<!-- ### Built With

* [![Next][Next.js]][Next-url]
* [![React][React.js]][React-url]
* [![Vue][Vue.js]][Vue-url]
* [![Angular][Angular.io]][Angular-url]
* [![Svelte][Svelte.dev]][Svelte-url]
* [![Laravel][Laravel.com]][Laravel-url]
* [![Bootstrap][Bootstrap.com]][Bootstrap-url]
* [![JQuery][JQuery.com]][JQuery-url] -->

<!-- <p align="right">(<a href="#readme-top">back to top</a>)</p> -->



<!-- GETTING STARTED -->
## Getting Started

Either grap the [.streamDeckPlugin File](https://github.com/VeeLume/sc-mapper-dart/releases/latest) to install the plugin or clone and install the project locally with the streamdeck cli

### Prerequisites


- [Dart](https://dart.dev/get-dart)
- [StreamDeck CLI](https://docs.elgato.com/streamdeck/cli/intro)

Technically you dont need the StreamDeck CLI but its useful.

### Installation

1. Clone the repo
   ```ps
   git clone https://github.com/VeeLume/sc-mapper-dart.git
   ```
2. Install dart packages
   ```ps
   dart pub get
   ```
3. Run build_runner
   ```ps
   dart run build_runner build
   ```
4. Compile exe
   ```ps
   dart compile exe .\bin\sc_mapper_dart.dart -o .\com.veelume.sc-mapper.sdPlugin\plugin.exe
   ```
5. Link the plugin directory
   ```ps
   streamdeck link .\icu.veelume.sc-mapper.sdPlugin\
   ```
6. If you make changes run
   ```ps
   streamdeck stop icu.veelume.sc-mapper
   dart compile exe .\bin\sc_mapper_dart.dart -o .\com.veelume.sc-mapper.sdPlugin\plugin.exe
   streamdeck restart icu.veelume.sc-mapper
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Current Limitations
- Settings are not implemented
- Only the live folder is considered (copy the files as workaround)
- Only keyboard binds are usable from the StreamDeck (mouse binds show up, but there is not logic to send those)
- The default bindings and translations are currently bundled instead of parsing from the p4k file

On the first start you need to use the Generate Binds Button. A short press loads the default bindings and the current custom bindings, a long press only the default bindings. After loading the bindings you will find a profile that you can import in the Star Citizen keybind options.

The Action Button is probably self explanatory, you can select an action for a short press and optionally an action for a long press.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

Currently there is no explicit plan. I have some ideas, but they are not concret currently.

See the [open issues](https://github.com/VeeLume/sc-mapper-dart/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Top contributors:

<a href="https://github.com/VeeLume/sc-mapper-dart/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=VeeLume/sc-mapper-dart" alt="contrib.rocks image" />
</a>



<!-- LICENSE -->
## License

Distributed under the project_license. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
<!-- ## Contact

Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - email@email_client.com

Project Link: [https://github.com/VeeLume/sc-mapper-dart](https://github.com/VeeLume/sc-mapper-dart)

<p align="right">(<a href="#readme-top">back to top</a>)</p> -->



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [streamdeck-starcitizen](https://github.com/mhwlng/streamdeck-starcitizen)
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/VeeLume/sc-mapper-dart.svg?style=for-the-badge
[contributors-url]: https://github.com/VeeLume/sc-mapper-dart/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/VeeLume/sc-mapper-dart.svg?style=for-the-badge
[forks-url]: https://github.com/VeeLume/sc-mapper-dart/network/members
[stars-shield]: https://img.shields.io/github/stars/VeeLume/sc-mapper-dart.svg?style=for-the-badge
[stars-url]: https://github.com/VeeLume/sc-mapper-dart/stargazers
[issues-shield]: https://img.shields.io/github/issues/VeeLume/sc-mapper-dart.svg?style=for-the-badge
[issues-url]: https://github.com/VeeLume/sc-mapper-dart/issues
[license-shield]: https://img.shields.io/github/license/VeeLume/sc-mapper-dart.svg?style=for-the-badge
[license-url]: https://github.com/VeeLume/sc-mapper-dart/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com
