import { z } from 'zod';

const CARS = [
  "Toyota Corolla",
  "Honda CRV",
  "Mercedes C300"
]

const TOOL = [
  "book-car",
  "Use this tool to book car rentals. Supported categories: 0-sedan, 1-suv, 2-luxury",
  {
    city: z.string(),
    date: z.string(),
    days: z.number(),
    category: z.number().optional()
  },
  async ({ city, date, days, category }, ctx) => {
    const car = CARS[category || 0];
    const userName = ctx.authInfo.user_name;
    return {
      content: [
        {
          type: "text",
          text: `Booked a ${car} for ${userName} in ${city} for ${days} days starting ${date}`
        }
      ]
    }
  }
];

export default TOOL;
