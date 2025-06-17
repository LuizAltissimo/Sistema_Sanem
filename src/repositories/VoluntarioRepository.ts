import { BaseRepository } from './BaseRepository';
import { Voluntario } from '../models/Voluntario';
import { PessoaRepository } from './PessoaRepository';

export class VoluntarioRepository extends BaseRepository<Voluntario> {
    private pessoaRepo: PessoaRepository;

    constructor() {
        super();
        this.pessoaRepo = new PessoaRepository();
    }

    async create(voluntario: Voluntario): Promise<Voluntario> {
        const result = await this.pool.query(
            'INSERT INTO Voluntario (id_pessoa, cargo, data_admissao) VALUES ($1, $2, $3) RETURNING *',
            [voluntario.getId(), voluntario.getCargo(), voluntario.getDataAdmissao()]
        );
        return new Voluntario(
            result.rows[0].id_voluntario,
            voluntario.getNome(),
            voluntario.getCpf(),
            voluntario.getTelefone(),
            voluntario.getEmail(),
            voluntario.getEndereco(),
            result.rows[0].cargo,
            result.rows[0].data_admissao
        );
    }

    async findById(id: number): Promise<Voluntario | null> {
        const result = await this.pool.query(
            'SELECT v.*, p.* FROM Voluntario v JOIN Pessoa p ON v.id_pessoa = p.id_pessoa WHERE v.id_voluntario = $1',
            [id]
        );
        if (result.rows.length === 0) {
            return null;
        }
        return new Voluntario(
            result.rows[0].id_voluntario,
            result.rows[0].nome,
            result.rows[0].cpf,
            result.rows[0].telefone,
            result.rows[0].email,
            result.rows[0].endereco,
            result.rows[0].cargo,
            result.rows[0].data_admissao
        );
    }

    async findAll(): Promise<Voluntario[]> {
        const result = await this.pool.query(
            'SELECT v.*, p.* FROM Voluntario v JOIN Pessoa p ON v.id_pessoa = p.id_pessoa'
        );
        return result.rows.map(row => new Voluntario(
            row.id_voluntario,
            row.nome,
            row.cpf,
            row.telefone,
            row.email,
            row.endereco,
            row.cargo,
            row.data_admissao
        ));
    }

    async update(voluntario: Voluntario): Promise<Voluntario> {
        const result = await this.pool.query(
            'UPDATE Voluntario SET cargo = $1, data_admissao = $2 WHERE id_voluntario = $3 RETURNING *',
            [voluntario.getCargo(), voluntario.getDataAdmissao(), voluntario.getId()]
        );
        return new Voluntario(
            result.rows[0].id_voluntario,
            voluntario.getNome(),
            voluntario.getCpf(),
            voluntario.getTelefone(),
            voluntario.getEmail(),
            voluntario.getEndereco(),
            result.rows[0].cargo,
            result.rows[0].data_admissao
        );
    }

    async delete(id: number): Promise<void> {
        await this.pool.query('DELETE FROM Voluntario WHERE id_voluntario = $1', [id]);
    }
} 