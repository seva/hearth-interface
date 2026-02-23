process.env.TZ = 'America/New_York';
console.log(new Date().toString());
console.log(new Date().toLocaleString('en-US', { timeZone: 'America/New_York' }));
