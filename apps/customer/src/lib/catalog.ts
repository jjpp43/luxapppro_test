export type CatalogProduct = {
  id: string;
  name: string;
  priceCents: number;
  category: string;
};

/** Demo Decatur shelf only. Replace with the Lightspeed copy later. */
export const CATALOG: CatalogProduct[] = [
  { id: "olaplex-3", name: "Olaplex No.3 Hair Perfector", priceCents: 3000, category: "Care" },
  { id: "olaplex-7", name: "Olaplex No.7 Bonding Oil", priceCents: 2800, category: "Care" },
  { id: "cantu", name: "Cantu Shea Leave In", priceCents: 800, category: "Care" },
  { id: "got2b", name: "Got2b Glued Spiking Gel", priceCents: 700, category: "Care" },
  { id: "redken-eq", name: "Redken Shades EQ Gloss", priceCents: 1800, category: "Color" },
  { id: "wella-k", name: "Wella Koleston Perfect", priceCents: 1200, category: "Color" },
  { id: "denman", name: "Denman D3 Brush", priceCents: 1400, category: "Tools" },
  { id: "og-ceramic", name: "Olivia Garden Ceramic Brush", priceCents: 1600, category: "Tools" },
  { id: "comb", name: "Wide tooth Comb", priceCents: 400, category: "Tools" },
  { id: "rods", name: "Annie Perm Rods (bag)", priceCents: 600, category: "Tools" },
  { id: "hot-tools", name: "Hot Tools 1\" Curling Iron", priceCents: 5200, category: "Tools" },
  { id: "flat", name: "Ceramic Flat Iron", priceCents: 4800, category: "Tools" },
  { id: "bundle", name: "Brazilian Bundle 16\"", priceCents: 4500, category: "Hair" },
  { id: "closure", name: "Lace Closure 4×4", priceCents: 3800, category: "Hair" },
  { id: "bonnet", name: "Satin Bonnet", priceCents: 900, category: "Accessories" },
  { id: "cape", name: "Shampoo Cape", priceCents: 1100, category: "Accessories" },
];

export const CATALOG_CATEGORIES = [
  "Care",
  "Color",
  "Tools",
  "Hair",
  "Accessories",
] as const;

export function productsByIds(ids: string[]): CatalogProduct[] {
  const byId = new Map(CATALOG.map((p) => [p.id, p]));
  return ids.flatMap((id) => {
    const product = byId.get(id);
    return product ? [product] : [];
  });
}

export function formatPrice(cents: number): string {
  return `$${(cents / 100).toFixed(0)}`;
}
