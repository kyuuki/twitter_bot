class Category < ActiveHash::Base
  self.data = [
    { id: 1, name_i18n: "category.weekday" },
    { id: 2, name_i18n: "category.random" },
    { id: 3, name_i18n: "category.schedule" },
    { id: 4, name_i18n: "category.priodical" },
    { id: 99999, name_i18n: "category.other" },
  ]

  def name
    I18n.t(self.name_i18n)
  end
end
