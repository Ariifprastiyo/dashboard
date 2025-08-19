document.addEventListener('DOMContentLoaded', function() {
  console.log('DOMContentLoaded');

  chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {
    var currentTab = tabs[0];
    var url = new URL(currentTab.url);
    var tiktokInfo = extractTikTokInfo(url);
    
    // var iframeUrl = new URL('http://localhost:3000/google_chrome_ext/popup');
    var iframeUrl = new URL('https://dashboard.mediarumu.com/google_chrome_ext/popup');
    iframeUrl.searchParams.append('tiktok_username', tiktokInfo.username);
    iframeUrl.searchParams.append('tiktok_video_id', tiktokInfo.videoId);
    
    document.getElementById('app-frame').src = iframeUrl.toString();
  });
});

function extractTikTokInfo(url) {
  if (url.hostname === 'www.tiktok.com') {
    const pathParts = url.pathname.split('/');
    // Check if the URL matches the pattern for a video page
    if (pathParts.length >= 4 && pathParts[2] === 'video') {
      return {
        username: pathParts[1].replace('@', ''),
        videoId: pathParts[3]
      };
    }
  }
  // Return null values if it's not a video page or not a TikTok URL
  return { username: null, videoId: null };
}
