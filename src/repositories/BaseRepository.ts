import { Database } from '../config/Database';
import { Base } from '../models/Base';

export abstract class BaseRepository<T extends Base> {
    protected pool = Database.getInstance().getPool();

    abstract create(entity: T): Promise<T>;
    abstract findById(id: number): Promise<T | null>;
    abstract findAll(): Promise<T[]>;
    abstract update(entity: T): Promise<T>;
    abstract delete(id: number): Promise<void>;
} 