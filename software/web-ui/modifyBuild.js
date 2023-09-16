const fs = require('fs');
const path = require('path');

const indexPath = path.join(__dirname, 'dist', 'index.html');
const fileContent = fs.readFileSync(indexPath, 'utf-8');

const replacementScript = `
<link rel="stylesheet" href="styleURL">
<script>
  window.addEventListener('load', function() {
    setTimeout(function() {
      var script = document.createElement('script');
      script.type = 'module';
      script.crossOrigin = true;
      script.src = scriptURL;
      document.body.appendChild(script);
    }, 250);
  });
</script>
`;

const scriptTagRegex = /<script type="module" crossorigin src="([^"]+)"><\/script>/;
const linkTagRegex = /<link rel="stylesheet" href="([^"]+)">/;

const scriptMatch = fileContent.match(scriptTagRegex);
const linkMatch = fileContent.match(linkTagRegex);

if (scriptMatch && linkMatch) {
  const scriptURL = scriptMatch[1];
  const styleURL = linkMatch[1];
  const modifiedContent = fileContent.replace(scriptTagRegex, "").replace(linkTagRegex, replacementScript.replace('scriptURL', JSON.stringify(scriptURL)).replace('styleURL', styleURL));

  fs.writeFileSync(indexPath, modifiedContent);
} else {
  console.error("Couldn't find the script or link tag in index.html.");
}
