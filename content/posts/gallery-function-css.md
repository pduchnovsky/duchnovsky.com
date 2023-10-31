+++
categories = ["guides"]
date = 2020-11-11T23:00:00Z
description = "Just recently I was looking for a way on how to simply (without JS) make gallery page for my portfolio and made this css out of many guides on the internet :)"
externalLink = ""
images = ["/images/example.KPaZ9hTQEh.jpg"]
slug = "gallery-function-css"
tags = ["css", "web"]
title = "CSS Gallery functionality for practically any SSG"

+++
Just recently I was looking for a way on how to simply (without JS) make gallery page for my portfolio and made this css out of many guides on the internet :)

Simply add this to your css code and try playing with it, there are examples in the article below, you need to check them out on a tablet or a PC, on mobile they won't align due to responsiveness :)

```css
img {
  height: auto;
  max-width: 100%;
  pointer-events: none;
  -webkit-touch-callout: none; /* iOS Safari */
    -webkit-user-select: none; /* Safari */
     -khtml-user-select: none; /* Konqueror HTML */
       -moz-user-select: none; /* Old versions of Firefox */
        -ms-user-select: none; /* Internet Explorer/Edge */
            user-select: none; /* Non-prefixed version, currently
                                  supported by Chrome, Edge, Opera and Firefox */
}

img[alt~="_gallery"] {
  -moz-box-shadow:    0px 0px 3px rgba(0, 0, 0, .5), 0px 0px 10px rgba(0, 0, 0, 0.2);
  -webkit-box-shadow: 0px 0px 3px rgba(0, 0, 0, .5), 0px 0px 10px rgba(0, 0, 0, 0.2);
  box-shadow:         0px 0px 3px rgba(0, 0, 0, .5), 0px 0px 10px rgba(0, 0, 0, 0.2);
  border-radius: 5px;
  margin-bottom: 2%;
}

/* Aligning images only on tablet/pc, not mobile. */
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

/* Cleanup after gallery image */
p::after {
  content: "";
  clear: both;
  display: table;
}
```

**Once added, you can put images to your 'gallery' like this**

This is the markdown code which gets transformed to gallery below, with two spaces after each line:

```md
![_gallery <](/images/example.KPaZ9hTQEh.jpg)  
![_gallery >](/images/example.KPaZ9hTQEh.jpg)  
![_gallery <](/images/example.KPaZ9hTQEh.jpg)  
![_gallery >](/images/example.KPaZ9hTQEh.jpg)
```

## Testing with two spaces after

![_gallery <](/images/example.KPaZ9hTQEh.jpg)  
![_gallery >](/images/example.KPaZ9hTQEh.jpg)  
![_gallery <](/images/example.KPaZ9hTQEh.jpg)  
![_gallery >](/images/example.KPaZ9hTQEh.jpg)

This is the markdown code which gets transformed to gallery below, without two spaces after each line:

```md
![_gallery <](/images/example.KPaZ9hTQEh.jpg)
![_gallery >](/images/example.KPaZ9hTQEh.jpg)
![_gallery <](/images/example.KPaZ9hTQEh.jpg)
![_gallery >](/images/example.KPaZ9hTQEh.jpg)
```

## Testing without two spaces after

![_gallery <](/images/example.KPaZ9hTQEh.jpg)
![_gallery >](/images/example.KPaZ9hTQEh.jpg)
![_gallery <](/images/example.KPaZ9hTQEh.jpg)
![_gallery >](/images/example.KPaZ9hTQEh.jpg)