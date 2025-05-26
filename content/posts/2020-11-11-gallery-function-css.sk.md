+++
categories = ["navody"]
date = 2020-11-11T23:00:00
description = "Len nedávno som hľadal spôsob, ako jednoducho (bez JS) vytvoriť stránku galérie pre svoje portfólio a vytvoril tento css z mnohých návodov na internete :)"
externalLink = ""
images = ["images/example.KPaZ9hTQEh.jpg"]
slug = "funkcia-galerie-css"
tags = ["css", "web"]
title = "CSS funkcionalita galérie pre prakticky akýkoľvek SSG"

+++
Len nedávno som hľadal spôsob, ako jednoducho (bez JS) vytvoriť stránku galérie pre svoje portfólio a vytvoril tento css z mnohých návodov na internete :)

Jednoducho toto pridajte do svojho css kódu a skúste sa s tým hrať, v článku nižšie sú príklady, treba si ich pozrieť na tablete alebo PC, na mobile sa kvôli responsiveness nezarovnajú :)

```css
img {
  height: auto;
  max-width: 100%;
  pointer-events: none;
  -webkit-touch-callout: none; /* iOS Safari */
    -webkit-user-select: none; /* Safari */
     -khtml-user-select: none; /* Konqueror HTML */
       -moz-user-select: none; /* Staršie verzie Firefox */
        -ms-user-select: none; /* Internet Explorer/Edge */
            user-select: none; /* Neprefixovaná verzia, momentálne
                                  podporované v Chrome, Edge, Opera and Firefox */
}

img[alt~="_gallery"] {
  -moz-box-shadow:    0px 0px 3px rgba(0, 0, 0, .5), 0px 0px 10px rgba(0, 0, 0, 0.2);
  -webkit-box-shadow: 0px 0px 3px rgba(0, 0, 0, .5), 0px 0px 10px rgba(0, 0, 0, 0.2);
  box-shadow:         0px 0px 3px rgba(0, 0, 0, .5), 0px 0px 10px rgba(0, 0, 0, 0.2);
  border-radius: 5px;
  margin-bottom: 2%;
}

/* Zarovnávame obrázky len na tablete/pc, nie mobile. */
@media (min-width: 550px) {
  img[alt~="_gallery"] {
    max-width: 49%;
  }
  img[alt$=">"] {
    float: right;
  }

  img[alt$="<"] {
    float: left;
  }

  img[alt$="><"] {
    display: block;
    margin: auto;
    float: none;
  }
}

/* Vyčistenie po obrázku galérie */
p::after {
  content: "";
  clear: both;
  display: table;
}
```

**Po pridaní môžete takto vkladať obrázky do svojej „galérie“**

Toto je kód markdown, ktorý sa transformuje do galérie nižšie, s dvoma medzerami za každým riadkom:

```md
![_gallery <](images/example.KPaZ9hTQEh.jpg)  
![_gallery >](images/example.KPaZ9hTQEh.jpg)  
![_gallery <](images/example.KPaZ9hTQEh.jpg)  
![_gallery >](images/example.KPaZ9hTQEh.jpg)  
```

## Testovanie s dvoma medzerami po

![_gallery <](images/example.KPaZ9hTQEh.jpg)  
![_gallery >](images/example.KPaZ9hTQEh.jpg)  
![_gallery <](images/example.KPaZ9hTQEh.jpg)  
![_gallery >](images/example.KPaZ9hTQEh.jpg)  

Toto je kód markdown, ktorý sa transformuje do galérie nižšie, bez dvoch medzier za každým riadkom:

```md
![_gallery <](images/example.KPaZ9hTQEh.jpg)
![_gallery >](images/example.KPaZ9hTQEh.jpg)
![_gallery <](images/example.KPaZ9hTQEh.jpg)
![_gallery >](images/example.KPaZ9hTQEh.jpg)
```

## Testovanie bez dvoch medzier

![_gallery <](images/example.KPaZ9hTQEh.jpg)
![_gallery >](images/example.KPaZ9hTQEh.jpg)
![_gallery <](images/example.KPaZ9hTQEh.jpg)
![_gallery >](images/example.KPaZ9hTQEh.jpg)