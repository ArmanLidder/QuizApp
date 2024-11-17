export interface StoreItem {
    id: string;
    cost: number,
    itemType: 'image' | 'theme',
    name: string,
    source?: string,
}