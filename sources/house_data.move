module connect_train::house_data {

    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::package::{Self};

    const ECallerNotHouse: u64 = 0;

    public struct HouseData has key {
        id: UID,
        house: address,
        single_stake: u64,
        fees: Balance<SUI>,
        fee_rate: u64
    }

    public struct HouseCap has key {
        id: UID
    }

    public struct HOUSE_DATA has drop {}

    fun init(otw: HOUSE_DATA, ctx: &mut TxContext) {

        package::claim_and_keep(otw, ctx);

        let house_cap = HouseCap {
            id: object::new(ctx)
        };

        transfer::transfer(house_cap, ctx.sender());
    }

    public fun initialize_house_data(house_cap: HouseCap,ctx: &mut TxContext) {

        let house_data = HouseData {
            id: object::new(ctx),
            house: ctx.sender(),
            single_stake: 500_000_000, // 0.5 SUI.
            fees: balance::zero(),
            fee_rate: 500 // 5% in basis points.
        };

        let HouseCap { id } = house_cap;
        object::delete(id);

        transfer::share_object(house_data);
    }

    public fun claim_fees(_:&HouseCap,house_data: &mut HouseData, ctx: &mut TxContext) {
        assert!(ctx.sender() == house_data.house(), ECallerNotHouse);

        let total_fees = fees(house_data);
        let coin = coin::take(&mut house_data.fees, total_fees, ctx);
        transfer::public_transfer(coin, house_data.house());
    }

    public fun change_single_stake(_:&HouseCap,house_data: &mut HouseData, single_stake: u64, ctx: &mut TxContext) {
        assert!(ctx.sender() == house_data.house(), ECallerNotHouse);

        house_data.single_stake = single_stake;
    }

    public fun change_fee_rate(_:&HouseCap,house_data: &mut HouseData,new_rate: u64,ctx: &mut TxContext){
        assert!(ctx.sender() == house_data.house(),ECallerNotHouse);

        house_data.fee_rate = new_rate;
    }

    public(package) fun house(house_data: &HouseData): address {
        house_data.house
    }

    public(package) fun fees(house_data: &HouseData): u64 {
        house_data.fees.value()
    }

    public(package) fun single_stake(house_data: &HouseData):u64{
        house_data.single_stake
    }

    public(package) fun fee_rate(house_data: &HouseData): u64{
        house_data.fee_rate
    }

    public(package) fun borrow_mut_fee(house_data: &mut HouseData): &mut Balance<SUI>{
        &mut house_data.fees
    }

}
