/// Module: connect_train
module connect_train::connect_train {

    use std::vector;
    use sui::balance;
    use sui::balance::{Balance, value, split};
    use sui::coin;
    use sui::coin::{Coin};
    use sui::random;
    use sui::random::Random;
    use sui::sui::SUI;
    use sui::transfer;
    use connect_train::house_data::{HouseData, fees, borrow_mut_fee};

    const EPlayerMismatchFunction: u64 = 0;
    const EPlayerMismatchRound: u64 =1;

    public struct Game has key {
        id: UID,
        playerA: address,
        playerB: address,
        playerA_card: vector<u64>,
        playerB_card: vector<u64>,
        card_pool: vector<u64>,
        stake_pool: vector<Balance<SUI>>,
        round: u64,
    }

    public fun create(playerB: address,rand: &Random,ctx:&mut TxContext){
        let mut full_card = vector[
            1,2,3,4,5,6,7,8,9,10,11,12,13,
            1,2,3,4,5,6,7,8,9,10,11,12,13,
            1,2,3,4,5,6,7,8,9,10,11,12,13,
            1,2,3,4,5,6,7,8,9,10,11,12,13,
        ];
        let mut playB_full_card = vector::empty<u64>();
        let mut i =0u64;
        let mut generator = rand.new_generator(ctx);
        while (i < 26){
            let full_card_len = vector::length(&full_card);
            let rand_card = random::generate_u64_in_range(&mut generator,0,full_card_len-1);
            let single_card = vector::remove(&mut full_card,rand_card);
            vector::push_back(&mut playB_full_card,single_card);
            i = i + 1;
        };

        let game = Game {
            id: object::new(ctx),
            playerA: ctx.sender(),
            playerB,
            playerA_card:full_card,
            playerB_card:playB_full_card,
            card_pool:vector[],
            stake_pool: vector[],
            round:0,
        };
        transfer::share_object(game);
    }

    public fun playerA_place_card(game: &mut Game,rand: &Random,ctx: &mut TxContext): u64{

        assert!(ctx.sender() == game.playerA,EPlayerMismatchFunction);
        assert!(game.round % 2 == 0,EPlayerMismatchRound );

        let len = vector::length(&game.playerA_card);

        let mut generator = rand.new_generator(ctx); // 创建随机数生成器
        let rand_num = generator.generate_u64_in_range(0, len-1);
        let place_card = vector::remove(&mut game.playerA_card,rand_num);
        place_card
    }

    public fun playerB_place_card(game: &mut Game,rand: &Random,ctx: &mut TxContext): u64{

        assert!(ctx.sender() == game.playerB,EPlayerMismatchFunction);
        assert!(game.round % 2 != 0,EPlayerMismatchRound );

        let len = vector::length(&game.playerB_card);

        let mut generator = rand.new_generator(ctx); // 创建随机数生成器
        let rand_num = generator.generate_u64_in_range(0, len-1);
        let place_card = vector::remove(&mut game.playerB_card,rand_num);
        place_card
    }

    public entry fun playerA_play_game(house_data:&mut HouseData,game: &mut Game,coin: Coin<SUI>,rand: &Random,ctx: &mut TxContext){

        assert!(ctx.sender() == game.playerA,EPlayerMismatchFunction);
        assert!(game.round % 2 == 0,EPlayerMismatchRound );

        let mut stake = coin::into_balance(coin);
        pay_fee(house_data,&mut stake);

        vector::push_back(&mut game.stake_pool,stake);
        let num = playerA_place_card(game,rand,ctx);

        let (boolean,same_card_index) = vector::index_of(&game.card_pool,&num);
        let i = same_card_index;

        if(boolean){
            let mut wincoin_pool = balance::zero<SUI>();
            while (i < vector::length(&game.card_pool)){
                let wincard = vector::remove(&mut game.card_pool,i);
                vector::push_back(&mut game.playerA_card,wincard);
                let wincoin = vector::remove(&mut game.stake_pool,i);
                wincoin_pool.join(wincoin);
            };
            let last_stake_pool = vector::length(&game.stake_pool);
            wincoin_pool.join(vector::remove(&mut game.stake_pool,last_stake_pool - 1 ));
            transfer::public_transfer(coin::from_balance(wincoin_pool,ctx),ctx.sender());
            vector::push_back(&mut game.playerA_card, num);
        } else {
            vector::push_back(&mut game.card_pool,num);
        };

        game.round = game.round + 1;

    }

    public entry fun playerB_play_game(house_data:&mut HouseData,game: &mut Game,coin: Coin<SUI>,rand: &Random,ctx: &mut TxContext){

        assert!(ctx.sender() == game.playerB,EPlayerMismatchFunction);
        assert!(game.round % 2 != 0,EPlayerMismatchRound );

        let mut stake = coin::into_balance(coin);
        pay_fee(house_data,&mut stake);

        vector::push_back(&mut game.stake_pool,stake);
        let num = playerB_place_card(game,rand,ctx);

        let (boolean,same_card_index) = vector::index_of(&game.card_pool,&num);
        let i = same_card_index;

        if(boolean){
            let mut wincoin_pool = balance::zero<SUI>();
            while(i < vector::length(&game.card_pool)){
                let wincard = vector::remove(&mut game.card_pool,i);
                vector::push_back(&mut game.playerB_card,wincard);

                let wincoin = vector::remove(&mut game.stake_pool,i);
                wincoin_pool.join(wincoin);
            };
            let last_stake_pool = vector::length(&game.stake_pool);
            wincoin_pool.join(vector::remove(&mut game.stake_pool,last_stake_pool - 1 ));
            transfer::public_transfer(coin::from_balance(wincoin_pool,ctx),ctx.sender());
            vector::push_back(&mut game.playerB_card, num);
        } else {
            vector::push_back(&mut game.card_pool,num);
        };

        game.round = game.round + 1;

    }

    public(package) fun pay_fee(house_data:&mut HouseData,balance: &mut Balance<SUI>){
        let fee = balance.value() * house_data.fee_rate() / 10000;
        let fees = balance.split(fee);
        let house_fees = borrow_mut_fee(house_data);
        house_fees.join(fees);
    }

}

