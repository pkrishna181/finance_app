/// Seed categories for the Indian market (v1).
class CategorySeed {
  const CategorySeed({
    required this.slug,
    required this.name,
    required this.sortOrder,
  });

  final String slug;
  final String name;
  final int sortOrder;
}

const kDefaultCategories = <CategorySeed>[
  CategorySeed(slug: 'groceries', name: 'Groceries', sortOrder: 10),
  CategorySeed(slug: 'food_delivery', name: 'Food Delivery', sortOrder: 20),
  CategorySeed(slug: 'transport', name: 'Transport', sortOrder: 30),
  CategorySeed(slug: 'fuel', name: 'Fuel', sortOrder: 40),
  CategorySeed(slug: 'utilities', name: 'Utilities', sortOrder: 50),
  CategorySeed(slug: 'rent', name: 'Rent', sortOrder: 60),
  CategorySeed(slug: 'emi', name: 'EMI', sortOrder: 70),
  CategorySeed(slug: 'investments_sip', name: 'Investments / SIP', sortOrder: 80),
  CategorySeed(slug: 'recharge', name: 'Recharge', sortOrder: 90),
  CategorySeed(slug: 'healthcare', name: 'Healthcare', sortOrder: 100),
  CategorySeed(slug: 'shopping', name: 'Shopping', sortOrder: 110),
  CategorySeed(slug: 'entertainment', name: 'Entertainment', sortOrder: 120),
  CategorySeed(slug: 'transfers_self', name: 'Transfers (self)', sortOrder: 130),
  CategorySeed(slug: 'transfers_others', name: 'Transfers (others)', sortOrder: 140),
  CategorySeed(slug: 'salary', name: 'Salary', sortOrder: 150),
  CategorySeed(slug: 'interest', name: 'Interest', sortOrder: 160),
  CategorySeed(slug: 'charges', name: 'Bank Charges', sortOrder: 170),
  CategorySeed(slug: 'uncategorized', name: 'Uncategorized', sortOrder: 999),
];
