import { BaseRepository } from './BaseRepository';
import { Item } from '../models/Item';

export class ItemRepository extends BaseRepository<Item> {
    async create(item: Item): Promise<Item> {
        const result = await this.pool.query(
            'INSERT INTO Item (tipo, descricao, tamanho, condicao, categoria, status) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
            [item.getTipo(), item.getDescricao(), item.getTamanho(), item.getCondicao(), item.getCategoria(), item.getStatus()]
        );
        return new Item(
            result.rows[0].id_item,
            result.rows[0].tipo,
            result.rows[0].descricao,
            result.rows[0].tamanho,
            result.rows[0].condicao,
            result.rows[0].categoria,
            result.rows[0].status
        );
    }

    async findById(id: number): Promise<Item | null> {
        const result = await this.pool.query('SELECT * FROM Item WHERE id_item = $1', [id]);
        if (result.rows.length === 0) {
            return null;
        }
        return new Item(
            result.rows[0].id_item,
            result.rows[0].tipo,
            result.rows[0].descricao,
            result.rows[0].tamanho,
            result.rows[0].condicao,
            result.rows[0].categoria,
            result.rows[0].status
        );
    }

    async findAll(): Promise<Item[]> {
        const result = await this.pool.query('SELECT * FROM Item');
        return result.rows.map(row => new Item(
            row.id_item,
            row.tipo,
            row.descricao,
            row.tamanho,
            row.condicao,
            row.categoria,
            row.status
        ));
    }

    async update(item: Item): Promise<Item> {
        const result = await this.pool.query(
            'UPDATE Item SET tipo = $1, descricao = $2, tamanho = $3, condicao = $4, categoria = $5, status = $6 WHERE id_item = $7 RETURNING *',
            [item.getTipo(), item.getDescricao(), item.getTamanho(), item.getCondicao(), item.getCategoria(), item.getStatus(), item.getId()]
        );
        return new Item(
            result.rows[0].id_item,
            result.rows[0].tipo,
            result.rows[0].descricao,
            result.rows[0].tamanho,
            result.rows[0].condicao,
            result.rows[0].categoria,
            result.rows[0].status
        );
    }

    async delete(id: number): Promise<void> {
        await this.pool.query('DELETE FROM Item WHERE id_item = $1', [id]);
    }
} 