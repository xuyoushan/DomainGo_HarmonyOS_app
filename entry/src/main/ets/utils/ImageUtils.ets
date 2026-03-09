export function getSafeAvatar(img: string | Resource | undefined): ResourceStr {
  if (!img) return $r('app.media.start');
  if (typeof img === 'object') return img as ResourceStr;
  if (img.startsWith('file://') || img.startsWith('http')) {
    return img as ResourceStr;
  }
  if (img.startsWith('/data/')) {
    return ('file://' + img) as ResourceStr;
  }
  return $r('app.media.start');
}
