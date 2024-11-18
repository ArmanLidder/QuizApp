export interface StoreItem {
    id: string;
    cost: number,
    itemType: 'image' | 'theme'| 'rewardImage' | 'rewardTheme',
    name: string,
    source?: string,
    minLevel?:number,
    achievement?:number,
}