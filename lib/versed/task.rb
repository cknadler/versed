module Versed
  class Task
    attr_accessor :category_id, :time_spent, :time_scheduled, :date

    def initialize(category_id, date)
      @category_id = category_id
      @date = date
    end

    def to_hash
      {
        "time_spent" => self.time_spent.to_s,
        "time_scheduled" => self.time_scheduled.to_s,
        "style" => style
      }
    end

    def time_spent
      Date.today > self.date ? @time_spent : nil
    end

    def time_scheduled
      Date.today > self.date ? @time_scheduled : nil
    end

    def time_spent?
      self.time_spent && self.time_spent > 0
    end

    def time_scheduled?
      self.time_scheduled && self.time_scheduled > 0
    end

    private

    DANGER_STYLE = "danger"
    WARN_STYLE = "warning"
    SUCCESS_STYLE = "success"
    ACTIVE_STYLE = "active"

    def style
      return ACTIVE_STYLE if self.date >= Date.today

      return unless self.time_scheduled && self.time_scheduled > 0

      if !self.time_spent || self.time_spent <= 0
        return DANGER_STYLE
      elsif self.time_spent < self.time_scheduled
        return WARN_STYLE
      else
        return SUCCESS_STYLE
      end
    end
  end
end
