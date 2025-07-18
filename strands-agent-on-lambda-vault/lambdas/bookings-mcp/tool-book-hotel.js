import { z } from 'zod';

const TOOL = [
  "book-hotel",
  "Use this tool to book hotels",
  {
    city: z.string(),
    date: z.string(),
    nights: z.number()
  },
  async ({ city, date, nights }, ctx) => {
    const userName = ctx.authInfo.user_name;
    return {
      content: [
        {
          type: "text",
          text: `Booked hotel in ${city} for ${userName} for ${nights} nights. Check-in date is ${date}.`
        }
      ]
    }
  }
];

export default TOOL;
