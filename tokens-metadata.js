const { writeFileSync } = require('fs');

Array.from({ length: 1000 }).forEach((_, i) => {
  writeFileSync(`./tokens-metadata/${i}`, JSON.stringify({
    id: i,
    name: `YFU Techne #${i}`,
    description: 'Hold this to receive the first edition of the yFu comic!',
    image: 'https://i.imgur.com/YoK9dVA.jpg'
  }));
})

// to generate files run "node tokens-metadata.js"