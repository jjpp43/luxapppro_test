export type StoreRow = {
  id: string;
  name: string;
  is_sandbox?: boolean | null;
};

export function isSandboxStore(store: StoreRow) {
  return Boolean(store.is_sandbox);
}

export function liveStores<T extends StoreRow>(stores: T[] | null | undefined) {
  return (stores ?? []).filter((store) => !isSandboxStore(store));
}

export function sandboxStoreIds(stores: StoreRow[] | null | undefined) {
  return (stores ?? []).filter(isSandboxStore).map((store) => store.id);
}
