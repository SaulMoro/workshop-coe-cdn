# Images and media

- Every `<img>` has `alt`. Describe what the image adds to the page; use `alt=""` when it is decoration.
- Set `width` and `height` (or an aspect ratio in CSS) so the layout does not jump when the file arrives.
- Images below the first screen get `loading="lazy"`. The main image of the page does not.
- Serve the size the layout needs, with `srcset` and `sizes` when the image changes size with the viewport.
- Icons that carry meaning have an accessible name; decorative icons get `aria-hidden="true"`.
