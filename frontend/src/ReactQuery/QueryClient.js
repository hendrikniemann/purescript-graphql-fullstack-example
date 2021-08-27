const { QueryClient } = require("react-query");

exports.createQueryClient = (options) => () => new QueryClient(options);

exports.invalidateQueries_ = (client, options) =>
  client.invalidateQueries(options);
