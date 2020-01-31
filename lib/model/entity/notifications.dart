class Notifications {
  int cinema;
  int aggregator;

  Notifications(this.cinema, this.aggregator);

  Map toJson() => {
    'cinema': cinema,
    'aggregator': aggregator,
  };
}