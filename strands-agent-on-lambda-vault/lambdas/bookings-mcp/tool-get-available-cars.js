const CARS = {
  'Toyota Corolla': 'Sedan',
  'Honda CRV': 'SUV',
  'Mercedes C300': 'Luxury'
}

const TOOL = [
  "get-available-cars",
  "This tool returns a list of available cars and their categories.",
  async (ctx) => {
    const userName = ctx.authInfo.user_name;

    return {
      content: [
        {
          type: "text",
          text: `Cars available for ${userName}: ${JSON.stringify(CARS)}`
        }
      ]
    }
  }
];

export default TOOL;
