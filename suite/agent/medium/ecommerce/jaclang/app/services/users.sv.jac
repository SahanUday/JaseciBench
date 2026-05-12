"""Users service: profile, addresses, payment methods."""

import from models { UserProfile, Address, PaymentMethod }
import from services.catalog { ensure_seeded }


def find_user(user_id: str) -> UserProfile | None {
    for u in [root() -->][?:UserProfile] {
        if u.id == user_id {
            return u;
        }
    }
    return None;
}


def find_address(user_id: str, address_id: str) -> Address | None {
    u = find_user(user_id);
    if u is None {
        return None;
    }
    for a in [u -->][?:Address] {
        if a.id == address_id {
            return a;
        }
    }
    return None;
}


def find_payment_method(user_id: str, pm_id: str) -> PaymentMethod | None {
    u = find_user(user_id);
    if u is None {
        return None;
    }
    for pm in [u -->][?:PaymentMethod] {
        if pm.id == pm_id {
            return pm;
        }
    }
    return None;
}


def user_dict(u: UserProfile) -> dict {
    return {
        "id": u.id,
        "username": u.username,
        "email": u.email,
        "first_name": u.first_name,
        "last_name": u.last_name,
    };
}


def address_dict(a: Address) -> dict {
    return {
        "id": a.id,
        "user_id": a.user_id,
        "address1": a.address1,
        "address2": a.address2,
        "city": a.city,
        "state": a.state,
        "zip_code": a.zip_code,
        "country": a.country,
        "is_default": a.is_default,
    };
}


def:pub list_users() -> list[dict] {
    ensure_seeded();
    return [user_dict(u) for u in [root() -->][?:UserProfile]];
}


def:pub get_profile(user_id: str) -> dict | None {
    ensure_seeded();
    u = find_user(user_id);
    if u is None {
        return None;
    }
    return user_dict(u);
}


def:pub list_addresses(user_id: str) -> list[dict] {
    ensure_seeded();
    u = find_user(user_id);
    if u is None {
        return [];
    }
    return [address_dict(a) for a in [u -->][?:Address]];
}


def:pub add_address(user_id: str, address1: str, city: str, state: str, zip_code: str, address2: str = "", country: str = "USA") -> dict {
    ensure_seeded();
    u = find_user(user_id);
    if u is None {
        return {"error": "User not found", "status": 404};
    }
    existing = [a for a in [u -->][?:Address]];
    addr_count = len(existing);
    aid = "addr_" + user_id + "_" + str(addr_count + 1);
    new_addr = Address(
        id=aid,
        user_id=user_id,
        address1=address1,
        address2=address2,
        city=city,
        state=state,
        zip_code=zip_code,
        country=country,
        is_default=(addr_count == 0),
    );
    u ++> new_addr;
    return address_dict(new_addr);
}


def:pub update_address(user_id: str, address_id: str, address1: str, city: str, state: str, zip_code: str, address2: str = "", country: str = "USA") -> dict {
    ensure_seeded();
    a = find_address(user_id, address_id);
    if a is None {
        return {"error": "Address not found", "status": 404};
    }
    a.address1 = address1;
    a.address2 = address2;
    a.city = city;
    a.state = state;
    a.zip_code = zip_code;
    a.country = country;
    return address_dict(a);
}


def:pub delete_address(user_id: str, address_id: str) -> dict {
    ensure_seeded();
    a = find_address(user_id, address_id);
    if a is None {
        return {"error": "Address not found", "status": 404};
    }
    del a;
    return {"deleted": address_id};
}


def:pub list_payment_methods(user_id: str) -> list[dict] {
    ensure_seeded();
    u = find_user(user_id);
    if u is None {
        return [];
    }
    return [
        {
            "id": pm.id,
            "user_id": pm.user_id,
            "card_brand": pm.card_brand,
            "last_four": pm.last_four,
            "is_default": pm.is_default,
        }
        for pm in [u -->][?:PaymentMethod]
    ];
}
