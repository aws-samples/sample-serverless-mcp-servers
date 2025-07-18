const TOOL = [
  "get-travel-policies",
  "This tool returns corporate travel policies. Travel agents must ALWAYS follow this guidance and restrictions.",
  async (ctx) => {
    const userName = ctx.authInfo.user_name;
    return {
      content: [
        {
          type: "text",
          text: `Here are the travel policies for ${userName}:
1. Employees can only book travel within the United States of America.
2. Employees are not allowed to book luxury cars.
3. Employees cannot travel for more than 5 days.
4. Employees can book business travel only, no leisure or personal travel is supported.
`
        }
      ]
    }
  }
];

export default TOOL;
